module intents.remotecontrol;

import openwebif.api;

import ask.ask;

import texts;

import skill;

///
final class IntentRCPlayPause : BaseIntent
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
		AlexaResult result;
		result.response.card.title = getText(TextId.RCPlayPauseCardTitle);
		result.response.card.content = getText(TextId.RCPlayPauseCardContent);
		return doRCIntent("PlayPause", apiClient, this, result);	
	}
}

///
final class IntentRCStop : BaseIntent
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
		AlexaResult result;
		result.response.card.title = getText(TextId.RCStopCardTitle);
		result.response.card.content = getText(TextId.RCStopCardContent);
		return doRCIntent("Stop", apiClient, this, result);	
	}
}

///
final class IntentRCPrevious : BaseIntent
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
		AlexaResult result;
		result.response.card.title = getText(TextId.RCPreviousCardTitle);
		result.response.card.content = getText(TextId.RCPreviousCardContent);
		return doRCIntent("Previous", apiClient, this, result);	
	}
}


///
static AlexaResult doRCIntent(string action, OpenWebifApi apiClient, ITextManager texts, AlexaResult result)
{
		import std.format : format;
		About boxinfo;
		try
			boxinfo = apiClient.about();
		catch (Exception e)
			return returnError(texts, e);
		
		int code;

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if (checkBox(boxinfo.info.imagedistro,action,code))
		{
			Remotecontrol rc;
			// is needed because an call on about doesn't need authorization - this one does - so catch auth errors
			try 
				rc = apiClient.remotecontrol(code); 
			catch(Exception e) 
				return returnError(texts, e);
			
			if(rc.result)
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
		return result;

}
///
private static bool checkBox(string info, string action, ref int code)
{
	auto key = info~"-"~action;
	foreach(i, entry; keyMap)
	{
		if(entry.action == key)
		{
			code = entry.code;
			return true;
		}

	}
	return false;
}


///
struct KeyMap
{
	string action;
	int code;
}

///
static immutable keyMap = [
	KeyMap("VTi-PlayPause", 207),
	KeyMap("VTi-Stop", 128),
	KeyMap("VTi-Previous", 412),
	KeyMap("openatv-PlayPause", 207),
	KeyMap("openatv-Stop", 128),
	KeyMap("openatv-Previous", 412)
];
