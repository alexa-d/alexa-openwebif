module intents.movies;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentMovies : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		import std.format : format;

		MovieList movies;
		AlexaResult result;
		try
			movies = apiClient.movielist();
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.MoviesCardTitle);

		string moviesList;

		foreach (movie; movies.movies)
		{
			moviesList ~= "<p>" ~ movie.eventname ~ "</p>";
		}

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.MoviesSSML), moviesList);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);

		return result;
	}
}
