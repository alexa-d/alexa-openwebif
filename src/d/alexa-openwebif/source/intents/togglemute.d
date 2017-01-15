module intents.togglemute;

import openwebif.api;

import ask.ask;

import texts;

///
final class IntentToggleMute : BaseIntent
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
		immutable res = apiClient.vol("mute");

		AlexaResult result;
		result.response.card.title =  getText(TextId.MuteCardTitle);
		result.response.card.content = getText(TextId.MuteCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.MuteFailedSSML);

		if(res.result && res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.MutedSSML);
		else if(res.result && !res.ismute)
			result.response.outputSpeech.ssml = getText(TextId.UnMutedSSML);

		return result;
	}
}
