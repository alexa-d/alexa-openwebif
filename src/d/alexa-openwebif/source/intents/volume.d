module intents.volume;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
abstract class VolumeBaseIntent : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	protected AlexaResult doVolumeIntent(bool increase, OpenWebifApi apiClient)
	{
		import std.format : format;

		auto action = "down";

		if (increase)
			action = "up";

		AlexaResult result;
		Vol res;
		try
			res = apiClient.vol(action);
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.SetVolumeCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.SetVolumeFailedSSML);
		if (res.result)
			result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeSSML), res.current);

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}

}

///
final class IntentVolumeDown : VolumeBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		return doVolumeIntent(false, apiClient);
	}
}

///
final class IntentVolumeUp : VolumeBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		return doVolumeIntent(true, apiClient);
	}
}

///
final class IntentSetVolume : VolumeBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent event, AlexaContext)
	{
		import std.format : format;
		import std.conv : to;

		auto targetVolume = to!int(event.request.intent.slots["targetVolume"].value);

		AlexaResult result;
		result.response.card.title = getText(TextId.SetVolumeCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.SetVolumeFailedSSML);

		if (targetVolume >= 0 && targetVolume <= 100)
		{
			Vol res;
			try
				res = apiClient.vol("set" ~ to!string(targetVolume));
			catch (Exception e)
				return returnError(e);

			if (res.result)
				result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeSSML),
						res.current);
		}
		else
		{
			result.response.outputSpeech.ssml = format(getText(TextId.SetVolumeRangeErrorSSML),
					to!string(targetVolume));
		}

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}
