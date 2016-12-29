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

int main(string[] args)
{
  import std.process;

  auto baseUrl = environment["OPENWEBIF_URL"];

  runTask({

    auto apiClient = new RestInterfaceClient!OpenWebifApi(baseUrl ~ "/api/");

    parseMovieList(apiClient.movielist());
  });

  return runEventLoop();
}
