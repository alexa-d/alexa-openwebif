module intents.services;

import openwebif.api;

import ask.ask;

import texts;
import skill;

///
final class IntentServices : BaseIntent
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

		auto serviceList = removeMarkers(apiClient.getallservices());

		AlexaResult result;
		result.response.card.title = getText(TextId.ChannelsCardTitle);
		result.response.card.content = getText(TextId.ChannelsCardContent);

		string channels;

		foreach(service; serviceList.services)
		{
			foreach(subservice; service.subservices) {
				channels ~= format("<p>%s</p>",subservice.servicename);
			}
		}
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml =
			format(getText(TextId.ChannelsSSML),channels);

		return result;
	}
}
