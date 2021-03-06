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

		if (apiClient.powerstate().instandby)
			return inStandby();

		About boxinfo;
		try
			boxinfo = apiClient.about();
		catch (Exception e)
			return returnError(e);

		int code;

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		// workaround for dreambox + openwebif #136 which has no imagedistro attribute
		string box;
		if (boxinfo.info.imagedistro.length == 0)
			box = boxinfo.info.brand;
		else
			box = boxinfo.info.imagedistro;

		if (checkBox(box, action, code))
		{
			Remotecontrol rc;

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

		result.response.outputSpeech.ssml = replaceSpecialChars(result.response.outputSpeech.ssml);
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
			412), KeyMap("openatv-PlayPause", 119), KeyMap("openatv-Stop",
			128), KeyMap("openatv-Previous", 412), KeyMap("Dream Multimedia-PlayPause",400),
			KeyMap("Dream Multimedia-Stop", 377)
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
		if (apiClient.powerstate().instandby)
			return inStandby();

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
		if (apiClient.powerstate().instandby)
			return inStandby();

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
		if (apiClient.powerstate().instandby)
			return inStandby();

		AlexaResult result;
		result.response.card.title = getText(TextId.RCPreviousCardTitle);
		return doRCIntent("Previous", apiClient, this, result);
	}
}
