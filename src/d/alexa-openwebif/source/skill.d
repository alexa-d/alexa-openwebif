module skill;

import vibe.d;
import ask.ask;
import openwebif.api;

import amazonlogin;
import
	lang.types,
	lang.lang_en,
	lang.lang_de;

///
final class OpenWebifSkill : AlexaSkill!OpenWebifSkill
{
	private OpenWebifApi apiClient;
	private AmazonLoginApiFactory amazonLoginApiFactory = &createAmazonLoginApi;
	//TODO: move into base class
	private AlexaText[] texts;

	///
	this(string baseUrl, string locale)
	{
		apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

		import std.string:toLower;
		locale = locale.toLower;
		if(locale == "de-de")
			texts = AlexaText_de;
		else
			texts = AlexaText_en;
	}

	///
	//TODO: move into base class
	string getText(int _key) const pure nothrow
	{
		assert(_key == texts[_key].key);
		return texts[_key].text;
	}

	///
	override AlexaResult onLaunch(AlexaEvent event, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.DefaultCardTitle);

		if(event.session.user.accessToken.length == 0)
		{
			result.response.card.content = getText(TextId.PleaseLogin);
			result.response.card.type = AlexaCard.Type.LinkAccount;
			result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
			result.response.outputSpeech.ssml = getText(TextId.PleaseLoginSSML);
		}
		else
		{
			auto loginApi = amazonLoginApiFactory(event.session.user.accessToken);

			import std.stdio:stderr;

			try{
				immutable tokenInfo = loginApi.tokeninfo(event.session.user.accessToken);
				stderr.writefln("tokenInfo: %s",tokenInfo);
			}
			catch(Exception e){
				stderr.writefln("tokenInfo parsing error: %s",e);
			}

			immutable userProfile = loginApi.profile();
			stderr.writefln("user: %s",userProfile);

			result.response.card.content = format(getText(TextId.HelloCardContent),userProfile.name);
			result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
			result.response.outputSpeech.ssml =
				.format(getText(TextId.HelloSSML),userProfile.name);
		}

		return result;
	}

	///
	unittest
	{
		import std.algorithm.searching:canFind;
		auto skill = new OpenWebifSkill("","de-DE");
		AlexaEvent ev;
		auto resp = skill.onLaunch(ev,AlexaContext.init);
		assert(resp.response.card.type == AlexaCard.Type.LinkAccount);

		skill.amazonLoginApiFactory = cast(AmazonLoginApiFactory)()
		{
			return new class AmazonLoginApi
			{
				TokenInfo tokeninfo(string){return TokenInfo();}
				UserProfile profile(){return UserProfile("foobar123");}
			};
		};

		ev.session.user.accessToken = "nonempty";
		resp = skill.onLaunch(ev,AlexaContext.init);
		assert(resp.response.card.type != AlexaCard.Type.LinkAccount);
		assert(canFind(resp.response.card.content, "foobar123"));
	}

	///
	private Subservice zapUpDown(string _action, ServicesList _allservices)
	{
		immutable currentservice = apiClient.getcurrent();

		import std.algorithm.searching:countUntil;
		static bool pred(Subservice subs, CurrentService curr)
		{
			return curr.info._ref == subs.servicereference;
		}

		immutable index = cast(int)countUntil!(pred)(_allservices.services[0].subservices,currentservice);

		immutable up = (_action=="up");
		auto j=0;
		if (up)
			j = index+1;
		else
			j = index-1;

		immutable maxIndex = cast(int)_allservices.services[0].subservices.length;

		// handle end or beginning of servicelist
		if (j >= maxIndex)
			j=0;
		else if (j<0)
			j = maxIndex -1;

		return _allservices.services[0].subservices[j];
	}

	///
	private Subservice zapTo (string _channel, ServicesList _allservices)
	{
		ulong minDistance = ulong.max;
		size_t minIndex;
		foreach(i, subservice; _allservices.services[0].subservices)
		{
			if(subservice.servicename.length < 2)
			continue;

			import std.algorithm:levenshteinDistance;

			auto dist = levenshteinDistance(subservice.servicename,_channel);
			if(dist < minDistance)
			{
				minDistance = dist;
				minIndex = i;
			}
		}
		return _allservices.services[0].subservices[minIndex];
	}

	///
	private ServicesList removeMarkers(ServicesList _list)
	{
		import std.algorithm.mutation:remove;
		auto i = 0;
		while(i < _list.services[0].subservices.length)
		{
			if(_list.services[0].subservices[i].servicereference.endsWith(_list.services[0].subservices[i].servicename))
			{
				_list.services[0].subservices = remove(_list.services[0].subservices,i);
				continue;
			}
			i++;
		}
		return _list;
	}

	///
	@CustomIntent("IntentAbout")
	AlexaResult onIntentAbout(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title =  getText(TextId.AboutCardTitle);
		result.response.card.content = getText(TextId.AboutCardContent);

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.AboutSSML);

		return result;
	}

	///
	@CustomIntent("IntentServices")
	AlexaResult onIntentServices(AlexaEvent, AlexaContext)
	{
		auto serviceList = removeMarkers(apiClient.getallservices());

		AlexaResult result;
		result.response.card.title = getText(TextId.ChannelsCardTitle);
		result.response.card.content = getText(TextId.ChannelsCardContent);

		string channels;

		foreach(service; serviceList.services)
		{
			foreach(subservice; service.subservices) {
				channels ~= "<p>" ~ subservice.servicename ~ "</p>";
			}
		}
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = 
			.format(getText(TextId.ChannelsSSML),channels);

		return result;
	}

	///
	@CustomIntent("IntentMovies")
	AlexaResult onIntentMovies(AlexaEvent, AlexaContext)
	{
		auto movies = apiClient.movielist();

		AlexaResult result;
		result.response.card.title = getText(TextId.MoviesCardTitle);
		result.response.card.content = getText(TextId.MoviesCardContent);

		string moviesList;

		foreach(movie; movies.movies)
		{
			moviesList ~= "<p>" ~ movie.eventname ~ "</p>";
		}

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = 
			.format(getText(TextId.MoviesSSML),moviesList);

		return result;
	}

	///
	@CustomIntent("IntentToggleMute")
	AlexaResult onIntentToggleMute(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.vol("mute");

		AlexaResult result;
		result.response.card.title =  getText(TextId.MuteCardTitle);
		result.response.card.content = getText(TextId.MuteCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.MuteFailedSSML);

		if(res.result && res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.MutedSSML);
		else if(res.result && !res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.UnMutedSSML);

		return result;
	}

	///
	@CustomIntent("IntentToggleStandby")
	AlexaResult onIntentToggleStandby(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.powerstate(0);

		AlexaResult result;
		result.response.card.title =  getText(TextId.StandbyCardTitle);
		result.response.card.content = getText(TextId.StandbyCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.StandbyFailedSSML);

		if(res.result && res.instandby)
			result.response.outputSpeech.ssml = getText(TextId.BoxStartedSSML);
		else if(res.result && !res.instandby)
			result.response.outputSpeech.ssml = getText(TextId.StandbySSML);

		return result;
	}

	///
	@CustomIntent("IntentVolumeDown")
	AlexaResult onIntentVolumeDown(AlexaEvent, AlexaContext)
	{
		return doVolumeIntent(false);
	}

	///
	@CustomIntent("IntentVolumeUp")
	AlexaResult onIntentVolumeUp(AlexaEvent, AlexaContext)
	{
		return doVolumeIntent(true);
	}

	///
	@CustomIntent("IntentSetVolume")
	AlexaResult onIntentSetVolume(AlexaEvent event, AlexaContext)
	{
		auto targetVolume = to!int(event.request.intent.slots["volume"].value);

		AlexaResult result;
		result.response.card.title =  getText(TextId.SetVolumeCardTitle);
		result.response.card.content = getText(TextId.SetVolumeCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.SetVolumeFailedSSML);

		if (targetVolume >=0 && targetVolume < 100)
		{
			auto res = apiClient.vol("set"~to!string(targetVolume));
			if (res.result)
				result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeSSML),res.current);
		}

		return result;
	}

	///
	@CustomIntent("IntentRecordNow")
	AlexaResult onIntentRecordNow(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.recordnow();

		AlexaResult result;
		result.response.card.title =  getText(TextId.RecordNowCardTitle);
		result.response.card.content = getText(TextId.RecordNowCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.RecordNowFailedSSML);
		if (res.result)
			result.response.outputSpeech.ssml = getText(TextId.RecordNowSSML);

		return result;
	}

	///
	private Subservice zapRandom(ServicesList _allservices)
	{
		import std.random:uniform;
		if (_allservices.services[0].subservices.length > 0)
		{
			auto i = uniform(0,_allservices.services[0].subservices.length-1);
			return _allservices.services[0].subservices[i];
		}
		Subservice _ret;
		return _ret;

	}

	///
	@CustomIntent("IntentZap")
	AlexaResult onIntentZap(AlexaEvent event, AlexaContext)
	{
		auto targetChannel = event.request.intent.slots["targetChannel"].value;
		Subservice matchedServices;
		auto switchedTo = getText(TextId.ZapFailedSSML);

		if(targetChannel.length > 0)
		{
			auto allservices = removeMarkers(apiClient.getallservices());

			if (targetChannel == "up" || targetChannel == "down")
			{
				matchedServices = zapUpDown(targetChannel, allservices);
			}
			else if (targetChannel == "random")
			{
				matchedServices = zapRandom(allservices);
			}
			else
			{
				matchedServices = zapTo(targetChannel, allservices);
			}
		}
		
		if(matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}
		AlexaResult result;
		result.response.card.title =  getText(TextId.ZapCardTitle);
		result.response.card.content = getText(TextId.ZapCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML),switchedTo);

		return result;
	}

	///
	@CustomIntent("IntentSleepTimer")
	AlexaResult onIntentSleepTimer(AlexaEvent event, AlexaContext)
	{
		auto minutes = to!int(event.request.intent.slots["minutes"].value);
		AlexaResult result;
		result.response.card.title =  getText(TextId.SleepTimerCardTitle);
		result.response.card.content = getText(TextId.SleepTimerCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if(minutes >= 0 && minutes < 999)
		{
			auto sleepTimer = apiClient.sleeptimer("get","standby",0, "False");
			if (sleepTimer.enabled)
			{
				if (minutes == 0)
				{
					sleepTimer = apiClient.sleeptimer("set","",0, "False");
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerOffSSML);
				}
				else
				{
					auto sleepTimerNew = apiClient.sleeptimer("set","standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						.format(getText(TextId.SleepTimerResetSSML),sleepTimer.minutes,sleepTimerNew.minutes);
				}
			}
			else
			{
				if (minutes == 0)
				{
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerNoTimerSSML);
				}
				else if (minutes >0)
				{
					sleepTimer = apiClient.sleeptimer("set", "standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						.format(getText(TextId.SleepTimerSetSSML),sleepTimer.minutes);
				}
				else
				{
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerFailedSSML);
				}
			}
		}
		else
		{
			result.response.outputSpeech.ssml = getText(TextId.SleepTimerFailedSSML);
		}

		return result;
	}

	///
	@CustomIntent("IntentCurrent")
	AlexaResult onIntentCurrent(AlexaEvent, AlexaContext)
	{
		auto currentService = apiClient.getcurrent();

		AlexaResult result;
		result.response.card.title =  getText(TextId.CurrentCardTitle);
		result.response.card.content = getText(TextId.CurrentCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.CurrentSSML),currentService.info._name,currentService.now.title);

		if(currentService.next.title.length > 0)
		{
			result.response.outputSpeech.ssml =
				format(getText(TextId.CurrentNextSSML),result.response.outputSpeech.ssml.replace("</speak>","") ,currentService.next.title);
		}

		return result;
	}

	///
	private AlexaResult doVolumeIntent(bool increase)
	{
		auto action = "down";

		if(increase)
			action = "up";

		auto res = apiClient.vol(action);

		AlexaResult result;
		result.response.card.title =  getText(TextId.SetVolumeCardTitle);
		result.response.card.content = getText(TextId.SetVolumeCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.SetVolumeFailedSSML);
		if (res.result)
			result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeSSML),res.current);

		return result;
	}
}

unittest
{
	auto skill = new OpenWebifSkill ("","de-DE");
	assert(skill.getText(TextId.PleaseLogin) == AlexaText_de[TextId.PleaseLogin].text);
	skill = new OpenWebifSkill ("","en-US");
	assert(skill.getText(TextId.PleaseLogin) == AlexaText_en[TextId.PleaseLogin].text);
}

unittest
{
	// check indices of language keys
	foreach(i,text; AlexaText_de){assert(text.key == i);}
	foreach(i,text; AlexaText_en){assert(text.key == i);}
}
