module intents.current;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentCurrent : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		import std.format : format;
		import std.string : replace;

		CurrentService currentService;

		try
			currentService = apiClient.getcurrent();
		catch (Exception e)
			return returnError(e);

		AlexaResult result;
		result.response.card.title = getText(TextId.CurrentCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		if (currentService.next.title.length > 0)
		{
			result.response.outputSpeech.ssml = format(getText(TextId.CurrentNextSSML),
					currentService.info._name, currentService.now.title,
					currentService.next.title);
		}
		else
		{
			result.response.outputSpeech.ssml = format(getText(TextId.CurrentSSML),
					currentService.info._name, currentService.now.title);
		}

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}
