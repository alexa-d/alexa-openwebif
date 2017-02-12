module intents.movies;

import openwebif.api;

import ask.ask;

import texts;

import skill;

///
final class IntentMovies : BaseIntent
{
	private OpenWebifApi apiClient;

	///
	this(OpenWebifApi api)
	{
		apiClient = api;
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		import std.format:format;
		MovieList movies;
		AlexaResult result;
		try
		{
			movies = apiClient.movielist();
		}
		catch (Exception e)
		{
			result = returnError(this);
			return result;
		}


		result.response.card.title = getText(TextId.MoviesCardTitle);
		result.response.card.content = getText(TextId.MoviesCardContent);

		string moviesList;

		foreach(movie; movies.movies)
		{
			moviesList ~= "<p>" ~ movie.eventname ~ "</p>";
		}

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml =
			format(getText(TextId.MoviesSSML),moviesList);

		return result;
	}
}
