module intents.recordnow;

import openwebif.api;

import ask.ask;

import texts;
///
final class IntentRecordNow : BaseIntent
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
		immutable res = apiClient.recordnow();

		AlexaResult result;
		result.response.card.title =  getText(TextId.RecordNowCardTitle);
		result.response.card.content = getText(TextId.RecordNowCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.RecordNowFailedSSML);
		if (res.result)
			result.response.outputSpeech.ssml = getText(TextId.RecordNowSSML);

		return result;
	}
}

