module skill;

import vibe.d;
import ask.ask;
import openwebif.api;

import amazonlogin;
import texts;
import
	intents.about,
	intents.current,
	intents.movies,
	intents.recordnow,
	intents.services,
	intents.sleeptimer,
	intents.togglemute,
	intents.togglestandby,
	intents.volume,
	intents.zap;

///
final class OpenWebifSkill : AlexaSkill!OpenWebifSkill
{
	private OpenWebifApi apiClient;
	private AmazonLoginApiFactory amazonLoginApiFactory = &createAmazonLoginApi;

	///
	this(string baseUrl, string locale)
	{
		apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

		import std.string:toLower;
		locale = locale.toLower;
		immutable isLangDe = locale == "de-de";

		super(isLangDe ? AlexaText_de : AlexaText_en);

		this.addIntent(new IntentAbout());
		this.addIntent(new IntentCurrent(apiClient));
		this.addIntent(new IntentMovies(apiClient));
		this.addIntent(new IntentRecordNow(apiClient));
		this.addIntent(new IntentServices(apiClient));
		this.addIntent(new IntentSleepTimer(apiClient));
		this.addIntent(new IntentToggleMute(apiClient));
		this.addIntent(new IntentToggleStandby(apiClient));
		this.addIntent(new IntentVolumeUp(apiClient));
		this.addIntent(new IntentVolumeDown(apiClient));
		this.addIntent(new IntentSetVolume(apiClient));
		this.addIntent(new IntentZapTo(apiClient));
		this.addIntent(new IntentZapUp(apiClient));
		this.addIntent(new IntentZapDown(apiClient));
		this.addIntent(new IntentZapRandom(apiClient));
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
}

///
static ServicesList removeMarkers(ServicesList _list)
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

//TODO: move to baselib
unittest
{
	auto skill = new OpenWebifSkill ("","de-DE");
	assert(skill.getText(TextId.PleaseLogin) == AlexaText_de[TextId.PleaseLogin].text);
	skill = new OpenWebifSkill ("","en-US");
	assert(skill.getText(TextId.PleaseLogin) == AlexaText_en[TextId.PleaseLogin].text);
}
