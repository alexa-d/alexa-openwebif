import std.stdio;
import std.xml;
import std.string;
import std.algorithm.searching;

import vibe.d;
import ask.ask;
import openwebif.api;

import amazonlogin;

int main(string[] args)
{
	import std.process:environment;
	immutable baseUrl = environment["OPENWEBIF_URL"];

	if(args.length != 4)
		return -1;

	immutable testingMode = args[1] == "true";

	string eventParamStr = args[2];
	string contextParamStr = args[3];

	if(!testingMode)
	{
		import std.base64:Base64;
		eventParamStr = cast(string)Base64.decode(eventParamStr);
		contextParamStr = cast(string)Base64.decode(contextParamStr);
	}

	auto eventJson = parseJson(eventParamStr);
	auto contextJson = parseJson(contextParamStr);

	AlexaEvent event;
	try{
		event = deserializeJson!AlexaEvent(eventJson);
	}
	catch(Exception e){
		stderr.writefln("could not deserialize event: %s",e);
	}

	AlexaContext context;
	try{
		context = deserializeJson!AlexaContext(contextJson);
	}
	catch(Exception e){
		stderr.writefln("could not deserialize context: %s",e);
	}

	auto skill = new OpenWebifSkill(baseUrl);

	return skill.execute(event, context);
}

///
final class OpenWebifSkill : AlexaSkill!OpenWebifSkill
{
	private OpenWebifApi apiClient;

	///
	this(string baseUrl)
	{
		apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");
	}

	override AlexaResult onLaunch(AlexaEvent event, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = "Webif";

		if(event.session.user.accessToken.length == 0)
		{
			result.response.card.content = "Webif please login";
			result.response.card.type = AlexaCard.Type.LinkAccount;
			result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
			result.response.outputSpeech.ssml = "<speak>Bitte log dich in deiner Alexa App ein</speak>";
		}
		else
		{
			//verify our client-app-id:
			//https://api.amazon.com/auth/o2/tokeninfo?access_token=' . urlencode($_REQUEST['access_token']));

			//grab user name using authToken
			//'https://api.amazon.com/user/profile'
			//curl_setopt($c, CURLOPT_HTTPHEADER, array('Authorization: bearer ' . $_REQUEST['access_token']));
			//curl_setopt($c, CURLOPT_RETURNTRANSFER, true);

			auto loginApi = createAmazonLoginApi(event.session.user.accessToken);

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

			result.response.card.content = "Webif says hello to: "~userProfile.name;
			result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
			result.response.outputSpeech.ssml =
				.format("<speak>Hallo %s, danke fürs einloggen. Was kann ich für dich tun?</speak>",userProfile.name);
		}

		return result;
	}

	///
	@CustomIntent("IntentServices")
	AlexaResult onIntentServices(AlexaEvent, AlexaContext)
	{
		auto serviceList = apiClient.getallservices();

		AlexaResult result;
		result.response.card.title = "Webif Kanäle";
		result.response.card.content = "Webif Kanalliste...";

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Du hast die folgenden Kanäle:";

		foreach(service; serviceList.services)
		{
			foreach(subservice; service.subservices) {

				result.response.outputSpeech.ssml ~= "<p>" ~ subservice.servicename ~ "</p>";
			}
		}

		result.response.outputSpeech.ssml ~= "</speak>";

		return result;
	}

	///
	@CustomIntent("IntentMovies")
	AlexaResult onIntentMovies(AlexaEvent, AlexaContext)
	{
		auto movies = apiClient.movielist();

		AlexaResult result;
		result.response.card.title = "Webif movies";
		result.response.card.content = "Webif movie liste...";

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Du hast die folgenden Filme:";

		foreach(movie; movies.movies)
		{
			result.response.outputSpeech.ssml ~= "<p>" ~ movie.eventname ~ "</p>";
		}

		result.response.outputSpeech.ssml ~= "</speak>";

		return result;
	}

	///
	@CustomIntent("IntentToggleMute")
	AlexaResult onIntentToggleMute(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.vol("mute");

		AlexaResult result;
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Stummschalten fehlgeschlagen</speak>";

		if(res.result && res.ismute)
			result.response.outputSpeech.ssml = "<speak>Stumm geschaltet</speak>";
		else if(res.result && !res.ismute)
			result.response.outputSpeech.ssml = "<speak>Stummschalten abgeschaltet</speak>";

		return result;
	}

	///
	@CustomIntent("IntentToggleStandby")
	AlexaResult onIntentToggleStandby(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.powerstate(0);

		AlexaResult result;
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Standby fehlgeschlagen</speak>";

		if(res.result && res.instandby)
			result.response.outputSpeech.ssml = "<speak>Box gestartet</speak>";
		else if(res.result && !res.instandby)
			result.response.outputSpeech.ssml = "<speak>Box in Standby geschaltet</speak>";

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
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Lautstärke anpassen fehlgeschlagen</speak>";

		if (targetVolume >=0 && targetVolume < 100)
		{
			auto res = apiClient.vol("set"~to!string(targetVolume));
			if (res.result)
				result.response.outputSpeech.ssml = format("<speak>Lautstärke auf %s gesetzt</speak>",res.current);
		}

		return result;
	}

	///
	@CustomIntent("IntentRecordNow")
	AlexaResult onIntentRecordNow(AlexaEvent, AlexaContext)
	{
		immutable res = apiClient.recordnow();

		AlexaResult result;
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Aufnahme starten fehlgeschlagen</speak>";
		if (res.result)
			result.response.outputSpeech.ssml = "<speak>Aufnahme gestartet</speak>";

		return result;
	}

 ///
  @CustomIntent("IntentZap")
  AlexaResult onIntentZap(AlexaEvent event, AlexaContext context)
  {
    auto targetChannel = event.request.intent.slots["targetChannel"].value;
    Subservice matchedServices; 
    auto switchedTo = "nichts";
   
    if(targetChannel.length > 0)
    {
      auto allservices = apiClient.getallservices();
      immutable auto maxIndex = allservices.services[0].subservices.length;

      if (targetChannel == "up" || targetChannel == "down")
      {
        auto j=0;
        auto up = false;
        
        if (targetChannel=="up") 
          up = true;
        
        auto currentservice = apiClient.getcurrent();
           
        bool pred(Subservice subs, CurrentService curr) 
        {
          return curr.info._ref == subs.servicereference;      
        }

        immutable auto i = countUntil!(pred)(allservices.services[0].subservices,currentservice);
     
        if (targetChannel == "up") 
        {
          up = true;
          j = i+1;
        }
        else
          j = i-1;

        // handle end or beginning of servicelist 
        if (j >= maxIndex)
          j=0;
        else if (j<=0)
          j = maxIndex-1;
        
        matchedServices = allservices.services[0].subservices[j];

        // handle bouquets headlines/titles
        while(matchedServices.servicereference.endsWith(matchedServices.servicename)) 
        {
          if (up)
            j++;
          else
            j--;
        
          if (j >= maxIndex)
            j=0;
          else if (j<=0)
            j = maxIndex-1;

          matchedServices = allservices.services[0].subservices[j];
        }      
      }  else
      {
        ulong minDistance = ulong.max;
        size_t minIndex;
        foreach(i, subservice; allservices.services[0].subservices)
        {
          if(subservice.servicename.length < 2)
            continue;

          import std.algorithm:levenshteinDistance;
      
          auto dist = levenshteinDistance(subservice.servicename,targetChannel);
          if(dist < minDistance)
          {
            minDistance = dist;
            minIndex = i;
          }
        
        }
        matchedServices = allservices.services[0].subservices[minIndex];
       }
    }
    
    apiClient.zap(matchedServices.servicereference);
    switchedTo = matchedServices.servicename;
    AlexaResult result;
    result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
    result.response.outputSpeech.ssml = "<speak>Ich habe umgeschaltet zu: <p>"~ switchedTo ~"</p></speak>";

    return result;
  }

	///
	@CustomIntent("IntentSleepTimer")
	AlexaResult onIntentSleepTimer(AlexaEvent event, AlexaContext)
	{
		auto minutes = to!int(event.request.intent.slots["minutes"].value);
		AlexaResult result;
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if(minutes >= 0 && minutes < 999)
		{
			auto sleepTimer = apiClient.sleeptimer("get","standby",0, "False");
			if (sleepTimer.enabled)
			{
				if (minutes == 0)
				{
					sleepTimer = apiClient.sleeptimer("set","",0, "False");
					result.response.outputSpeech.ssml = "<speak>Sleep Timer wurde deaktiviert</speak>";
				}
				else
				{
					auto sleepTimerNew = apiClient.sleeptimer("set","standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						.format("<speak>Es existiert bereits ein Sleep Timer mit <p>%s verbleibenden Minuten."~
							"Timer wurde auf %s Minuten zurückgesetzt.</p></speak>",sleepTimer.minutes,sleepTimerNew.minutes);
				}
			}
			else
			{
				if (minutes == 0)
				{
					result.response.outputSpeech.ssml = "<speak>Es gibt keinen Timer der deaktiviert werden könnte</speak>";
				}
				else if (minutes >0)
				{
					sleepTimer = apiClient.sleeptimer("set", "standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						.format("<speak>Ich habe den Sleep Timer auf <p>%s Minuten eingestellt</p></speak>",sleepTimer.minutes);
				}
				else
				{
					result.response.outputSpeech.ssml = "<speak>Der Timer konnte nicht gesetzt werden.</speak>";
				}
			}
		}
		else
		{
			result.response.outputSpeech.ssml = "<speak>Das kann ich leider nicht tun.</speak>";
		}

		return result;
	}

	///
	@CustomIntent("IntentCurrent")
	AlexaResult onIntentCurrent(AlexaEvent, AlexaContext)
	{
		auto currentService = apiClient.getcurrent();

		AlexaResult result;
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Du guckst gerade: <p>" ~ currentService.info._name ~
			"</p>Aktuell läuft:<p>" ~ currentService.now.title ~ "</p>";

		if(currentService.next.title.length > 0)
		{
			result.response.outputSpeech.ssml ~=
				" anschliessend läuft: <p>" ~ currentService.next.title ~ "</p>";
		}

		result.response.outputSpeech.ssml ~= "</speak>";

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
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = "<speak>Lautstärke anpassen fehlgeschlagen</speak>";
		if (res.result)
			result.response.outputSpeech.ssml = format("<speak>Lautstärke auf %s gesetzt</speak>",res.current);

		return result;
	}
}
