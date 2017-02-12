module intents.sleeptimer;

import openwebif.api;

import ask.ask;

import texts;

import skill;

///
final class IntentSleepTimer : BaseIntent
{
	private OpenWebifApi apiClient;

	///
	this(OpenWebifApi api)
	{
		apiClient = api;
	}

	///
	override AlexaResult onIntent(AlexaEvent event, AlexaContext)
	{
		import std.conv:to;
		import std.format:format;
		auto minutes = to!int(event.request.intent.slots["minutes"].value);
		AlexaResult result;
		result.response.card.title =  getText(TextId.SleepTimerCardTitle);
		result.response.card.content = getText(TextId.SleepTimerCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if(minutes >= 0 && minutes < 999)
		{
			SleepTimer sleepTimer;
			try
			{
				sleepTimer = apiClient.sleeptimer("get","standby",0, "False");
			}
			catch (Exception e)
			{
				result = returnError(this);
				return result;
			}
			if (sleepTimer.enabled)
			{
				if (minutes == 0)
				{
					sleepTimer = apiClient.sleeptimer("set","",0, "False");
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerOffSSML);
				}
				else
				{
					auto sleepTimerNew = apiClient.sleeptimer("set","standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						format(getText(TextId.SleepTimerResetSSML),sleepTimer.minutes,sleepTimerNew.minutes);
				}
			}
			else
			{
				if (minutes == 0)
				{
					result.response.outputSpeech.ssml = getText(TextId.SleepTimerNoTimerSSML);
				}
				else if (minutes >0)
				{
					sleepTimer = apiClient.sleeptimer("set", "standby", to!int(minutes), "True");
					result.response.outputSpeech.ssml =
						format(getText(TextId.SleepTimerSetSSML),sleepTimer.minutes);
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

		return result;
	}
}

