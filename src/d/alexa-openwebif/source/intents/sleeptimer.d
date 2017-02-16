module intents.sleeptimer;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentSleepTimer : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent event, AlexaContext)
	{
		import std.conv : to;
		import std.format : format;
		import std.stdio : stderr;
		int minutes;
		try
		{
			minutes = ISODurationToMinutes(event.request.intent.slots["targetMinutes"].value);
		}
		catch (Exception e)
		{
			return returnError(e);
		}
		AlexaResult result;
		result.response.card.title = getText(TextId.SleepTimerCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if (minutes >= 0 && minutes < 999)
		{
			SleepTimer sleepTimer;

			try
				sleepTimer = apiClient.sleeptimer("get", "standby", 0, "False");
			catch (Exception e)
				return returnError(e);

			if (sleepTimer.enabled)
			{
				if (minutes == 0)
				{
					sleepTimer = apiClient.sleeptimer("set", "", 0, "False");
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerOffSSML);
				}
				else
				{
					auto sleepTimerNew = apiClient.sleeptimer("set", "standby",
							to!int(minutes), "True");
					result.response.outputSpeech.ssml = format(getText(TextId.SleepTimerResetSSML),
							sleepTimer.minutes, sleepTimerNew.minutes);
				}
			}
			else
			{
				if (minutes == 0)
				{
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerNoTimerSSML);
				}
				else if (minutes > 0)
				{
					sleepTimer = apiClient.sleeptimer("set", "standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml = format(getText(TextId.SleepTimerSetSSML),
							sleepTimer.minutes);
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
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}

	///
	static int ISODurationToMinutes(string isoString)
	{
		import std.regex : regex, matchAll;
		import std.conv : to;

		auto expr = regex(`P((([0-9]*\.?[0-9]*)Y)?(([0-9]*\.?[0-9]*)M)?(([0-9]*\.?[0-9]*)W)?(([0-9]*\.?[0-9]*)D)?)?(T(([0-9]*\.?[0-9]*)H)?(([0-9]*\.?[0-9]*)M)?(([0-9]*\.?[0-9]*)S)?)?`);
		auto res = matchAll(isoString, expr);
		//only support hours minutes and seconds - formats like "PT..."
		if (res.front[1].length > 0)
			return -1;

		int secs, mins, hrs;
		if (res.front[16].length > 0) secs = to!int(res.front[16]);
		if (res.front[14].length > 0) mins = to!int(res.front[14]);
		if (res.front[12].length > 0) hrs = to!int(res.front[12]);
		return secs / 60 + mins + hrs * 60;
	}

	///
	unittest
	{
		assert (ISODurationToMinutes("PT10M") == 10);
		assert (ISODurationToMinutes("PT10M120S") == 12);
		assert (ISODurationToMinutes("PT10M80S") == 11);
		assert (ISODurationToMinutes("PT1H") == 60);
		assert (ISODurationToMinutes("PT2H10M") == 130);
		assert (ISODurationToMinutes("P2YT10M") == -1);
	}
}
