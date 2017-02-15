module intents.remotecontrol;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
abstract class RemoteControlBaseIntent : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	protected AlexaResult doRCIntent(string action, OpenWebifApi apiClient,
			ITextManager texts, AlexaResult result)
	{
		import std.format : format;

		About boxinfo;
		try
			boxinfo = apiClient.about();
		catch (Exception e)
			return returnError(e);

		int code;

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if (checkBox(boxinfo.info.imagedistro, action, code))
		{
			Remotecontrol rc;
			// is needed because an call on about doesn't need authorization - this one does - so catch auth errors
			try
				rc = apiClient.remotecontrol(code);
			catch (Exception e)
				return returnError(e);

			if (rc.result)
			{
				result.response.outputSpeech.ssml = texts.getText(TextId.RCOKSSML);
			}
			else
			{
				result.response.outputSpeech.ssml = texts.getText(TextId.RCFailedSSML);
			}
		}
		else
		{
			result.response.outputSpeech.ssml = texts.getText(TextId.NotSupportedSSML);
		}
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}

	///
	private static bool checkBox(string info, string action, ref int code)
	{
		immutable key = info ~ "-" ~ action;
		foreach (i, entry; KeyMappings)
		{
			if (entry.action == key)
			{
				code = entry.code;
				return true;
			}

		}
		return false;
	}

	///
	private struct KeyMap
	{
		string action;
		int code;
	}

	///
	private static immutable KeyMappings = [
		KeyMap("VTi-PlayPause", 207), KeyMap("VTi-Stop", 128), KeyMap("VTi-Previous",
			412), KeyMap("openatv-PlayPause", 207), KeyMap("openatv-Stop",
			128), KeyMap("openatv-Previous", 412)
	];
}

///
final class IntentRCPlayPause : RemoteControlBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.RCPlayPauseCardTitle);
		return doRCIntent("PlayPause", apiClient, this, result);
	}
}

///
final class IntentRCStop : RemoteControlBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.RCStopCardTitle);
		return doRCIntent("Stop", apiClient, this, result);
	}
}

///
final class IntentRCPrevious : RemoteControlBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.RCPreviousCardTitle);
		return doRCIntent("Previous", apiClient, this, result);
	}
}
