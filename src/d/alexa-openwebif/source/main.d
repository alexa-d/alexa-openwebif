import std.stdio;
import vibe.d;
import std.xml;
import std.string;

import openWebif;
import ask;

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

void intentServices(AlexaEvent event, AlexaRequestContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseServicesList(apiClient.getallservices());
  });
}

void intentMovies(AlexaEvent event, AlexaRequestContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseMovieList(apiClient.movielist());
  });
}

void intentCurrent(AlexaEvent event, AlexaRequestContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseCurrent(apiClient.getcurrent());
  });
}

void intentToggleMute(AlexaEvent event, AlexaRequestContext context)
{
  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    apiClient.vol("mute");

    AlexaResult result;
    result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
    result.response.outputSpeech.ssml = "<speak>Stummschalten umgeschaltet</speak>";
    
    writeln(serializeToJson(result).toPrettyString());

    exitEventLoop();
  });
}

string baseUrl;

int main(string[] args)
{
  import std.process:environment;
  baseUrl = environment["OPENWEBIF_URL"];

  if(args.length != 3)
    return -1;
  
  import std.base64;
  auto decodedArg1 = cast(string)Base64.decode(args[1]);
  auto decodedArg2 = cast(string)Base64.decode(args[2]);
  auto eventJson = parseJson(decodedArg1);
  auto contextJson = parseJson(decodedArg2);

  auto event = deserializeJson!AlexaEvent(eventJson);

  import std.stdio:stderr;
  stderr.writefln("event: %s\n",event);
  stderr.writefln("context: %s",contextJson.toPrettyString());

  runTask({
    if(event.request.intent.name == "IntentCurrent")
      intentCurrent(event, AlexaRequestContext.init);
    else if(event.request.intent.name == "IntentServices")
      intentServices(event, AlexaRequestContext.init);
    else if(event.request.intent.name == "IntentMovies")
      intentMovies(event, AlexaRequestContext.init);
     else if(event.request.intent.name == "IntentToggleMute")
      intentToggleMute(event, AlexaRequestContext.init);
    else
      exitEventLoop();
  });

  return runEventLoop();
}
