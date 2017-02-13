module intents.volume;

import openwebif.api;

import ask.ask;

import texts;

import skill;

///
final class IntentVolumeDown : BaseIntent
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
		return doVolumeIntent(false, apiClient, this);
	}
}

///
final class IntentVolumeUp : BaseIntent
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
		return doVolumeIntent(true, apiClient, this);
	}
}

///
final class IntentSetVolume : BaseIntent
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
		import std.format:format;
		import std.conv:to;
		auto targetVolume = to!int(event.request.intent.slots["targetVolume"].value);

		AlexaResult result;
		result.response.card.title =  getText(TextId.SetVolumeCardTitle);
		result.response.card.content = getText(TextId.SetVolumeCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.SetVolumeFailedSSML);

		if (targetVolume >=0 && targetVolume <= 100)
		{
			Vol res;
			try
				res = apiClient.vol("set"~to!string(targetVolume));
			catch (Exception e)
				return returnError(this, e);

			if (res.result)
				result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeSSML),res.current);
		}
		else
		{
			result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeRangeErrorSSML),to!string(targetVolume));
		}

		return result;
	}
}

///
static AlexaResult doVolumeIntent(bool increase, OpenWebifApi apiClient, ITextManager texts)
{
	import std.format:format;
	auto action = "down";

	if(increase)
		action = "up";

	AlexaResult result;
	Vol res;
	try
		res = apiClient.vol(action);
	catch (Exception e)
		return returnError(texts, e);

	result.response.card.title =  texts.getText(TextId.SetVolumeCardTitle);
	result.response.card.content = texts.getText(TextId.SetVolumeCardContent);
	result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
	result.response.outputSpeech.ssml = texts.getText(TextId.SetVolumeFailedSSML);
	if (res.result)
		result.response.outputSpeech.ssml = format(texts.getText(TextId.SetVolumeSSML),res.current);

	return result;
}
