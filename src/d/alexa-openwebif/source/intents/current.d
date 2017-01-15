module intents.current;

import openwebif.api;

import ask.ask;

import texts;
///
final class IntentCurrent : BaseIntent
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
		import std.format:format;
		import std.string:replace;
		auto currentService = apiClient.getcurrent();

		AlexaResult result;
		result.response.card.title =  getText(TextId.CurrentCardTitle);
		result.response.card.content = getText(TextId.CurrentCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.CurrentSSML),currentService.info._name,currentService.now.title);

		if(currentService.next.title.length > 0)
		{
			result.response.outputSpeech.ssml =
				format(getText(TextId.CurrentNextSSML),result.response.outputSpeech.ssml.replace("</speak>","") ,currentService.next.title);
		}

		return result;
	}
}

