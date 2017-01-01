import std.stdio;
import std.xml;
import std.string;

import vibe.d;
import ask.ask;

import openWebif;

void parseMovieList(MovieList movies)
{
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

  writeln(serializeToJson(result).toPrettyString());

  exitEventLoop();
}

void parseServicesList(ServicesList serviceList)
{
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

  writeln(serializeToJson(result).toPrettyString());

  exitEventLoop();
}

void parseCurrent(CurrentService currentService)
{
  AlexaResult result;
  auto nextTime = SysTime.fromUnixTime(currentService.next.begin_timestamp);

  result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
  result.response.outputSpeech.ssml = "<speak>Du guckst gerade: <p>" ~ currentService.info.name ~ 
    "</p>Aktuell läuft:<p>" ~ currentService.now.title ~ "</p>";

  if(currentService.next.title.length > 0)
  {
    result.response.outputSpeech.ssml ~=
      " anschliessend läuft: <p>" ~ currentService.next.title ~ "</p>";
  }

  result.response.outputSpeech.ssml ~= "</speak>";

  writeln(serializeToJson(result).toPrettyString());

  exitEventLoop();
}

void intentServices(AlexaEvent event, AlexaContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseServicesList(apiClient.getallservices());
  });
}

void intentMovies(AlexaEvent event, AlexaContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseMovieList(apiClient.movielist());
  });
}

void intentCurrent(AlexaEvent event, AlexaContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseCurrent(apiClient.getcurrent());
  });
}

void intentToggleMute(AlexaEvent event, AlexaContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    auto res = apiClient.vol("mute");

    AlexaResult result;
    result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
    result.response.outputSpeech.ssml = "<speak>Stummschalten fehlgeschlagen</speak>";

    if(res.result && res.ismute)
      result.response.outputSpeech.ssml = "<speak>Stumm geschaltet</speak>";
    else if(res.result && !res.ismute)
      result.response.outputSpeech.ssml = "<speak>Stummschalten abgeschaltet</speak>";

    writeln(serializeToJson(result).toPrettyString());

    exitEventLoop();
  });
}

void intentZap(AlexaEvent event, AlexaContext context)
{
  runTask({

    auto targetChannel = event.request.intent.slots["targetChannel"].value;

    auto switchedTo = "nichts";

    if(targetChannel.length > 0)
    {
      auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

      auto allservices = apiClient.getallservices();

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
          //stderr.writefln("better match found: %s (%s)",subservice,dist);
        }
      }

      auto matchedServices = allservices.services[0].subservices[minIndex];

      apiClient.zap(matchedServices.servicereference);

      switchedTo = matchedServices.servicename;
    }

    AlexaResult result;
    result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
    result.response.outputSpeech.ssml = "<speak>Ich habe umgeschaltet zu: <p>"~ switchedTo ~"</p></speak>";

    writeln(serializeToJson(result).toPrettyString());

    exitEventLoop();
  });
}

string baseUrl;

int main(string[] args)
{
  import std.process:environment;
  baseUrl = environment["OPENWEBIF_URL"];

  if(args.length != 4)
    return -1;
  
  auto testingMode = args[1] == "true";

  string eventParamStr = args[2];
  string contextParamStr = args[3];

  if(!testingMode)
  {
    import std.base64;
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

  import std.stdio:stderr;
  stderr.writefln("event: %s\n",event);
  stderr.writefln("context: %s",context);

  runTask({
    if(event.request.intent.name == "IntentCurrent")
      intentCurrent(event, context);
    else if(event.request.intent.name == "IntentServices")
      intentServices(event, context);
    else if(event.request.intent.name == "IntentMovies")
      intentMovies(event, context);
     else if(event.request.intent.name == "IntentToggleMute")
      intentToggleMute(event, context);
    else if(event.request.intent.name == "IntentZap")
      intentZap(event, context);
    else
      exitEventLoop();
  });

  return runEventLoop();
}
