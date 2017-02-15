module intents.togglemute;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentToggleMute : OpenWebifBaseIntent
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
		Vol res;
		try
			res = apiClient.vol("mute");
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.MuteCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.MuteFailedSSML);

		if (res.result && res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.MutedSSML);
		else if (res.result && !res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.UnMutedSSML);

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}
