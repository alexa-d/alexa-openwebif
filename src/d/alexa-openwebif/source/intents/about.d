module intents.about;

import ask.ask;

import texts;

///
final class IntentAbout : BaseIntent
{
	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title =  getText(TextId.AboutCardTitle);
		result.response.card.content = getText(TextId.AboutCardContent);

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.AboutSSML);

		return result;
	}
}
