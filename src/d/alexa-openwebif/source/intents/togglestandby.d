module intents.togglestandby;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentToggleStandby : OpenWebifBaseIntent
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
		PowerState res;
		try
			res = apiClient.powerstate(0);
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.StandbyCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.StandbyFailedSSML);

		if (res.result && res.instandby)
			result.response.outputSpeech.ssml = getText(TextId.BoxStartedSSML);
		else if (res.result && !res.instandby)
			result.response.outputSpeech.ssml = getText(TextId.StandbySSML);

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}
