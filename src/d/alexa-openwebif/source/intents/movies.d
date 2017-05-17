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
		import std.datetime : SysTime;
		import std.conv : to;

		if (apiClient.powerstate().instandby)
			return inStandby();

		MovieList movies;
		AlexaResult result;
		try
			movies = apiClient.movielist();
		catch (Exception e)
			return specificError(TextId.MoviesNoHDDTitle, TextId.MoviesNoHDDSSML);

		if (movies.movies.length <= 0)
		{
			return specificError(TextId.MoviesNoFilesTitle, TextId.MoviesNoFilesSSML);
		}

		result.response.card.title = getText(TextId.MoviesCardTitle);

		string moviesList;

		SysTime st;
		string dateString;
		string datessml;

		foreach (movie; movies.movies)
		{
			st = SysTime.fromUnixTime(movie.recordingtime);
			datessml = format("%02d.%02d.%s", st.day, to!int(st.month), st.year);
			moviesList ~= format("<p>%s %s</p>", movie.eventname, format(getText(TextId.MoviesDateSSML), datessml));
		}

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.MoviesSSML), moviesList);
		result.response.outputSpeech.ssml = replaceSpecialChars(result.response.outputSpeech.ssml);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);

		return result;
	}
}
