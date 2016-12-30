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
  writeln("test");

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

int main(string[] args)
{
  import std.process;

  auto baseUrl = environment["OPENWEBIF_URL"];

  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    //parseMovieList(apiClient.movielist());
    //parseServicesList(apiClient.getallservices());
    parseCurrent(apiClient.getcurrent());

  });

  return runEventLoop();
}
