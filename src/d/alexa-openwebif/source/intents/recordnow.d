module intents.recordnow;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentRecordNow : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		RecordNow res;
		AlexaResult result;
		try
			res = apiClient.recordnow();
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.RecordNowCardTitle);
		result.response.card.content = getText(TextId.RecordNowCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.RecordNowFailedSSML);
		if (res.result)
			result.response.outputSpeech.ssml = getText(TextId.RecordNowSSML);

		return result;
	}
}
