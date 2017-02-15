module intents.services;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
final class IntentServices : OpenWebifBaseIntent
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

		ServicesList serviceList;
		AlexaResult result;
		try
			serviceList = removeMarkers(apiClient.getallservices());
		catch (Exception e)
			return returnError(e);

		result.response.card.title = getText(TextId.ChannelsCardTitle);

		string channels;

		foreach (service; serviceList.services)
		{
			foreach (subservice; service.subservices)
			{
				channels ~= format("<p>%s</p>", subservice.servicename);
			}
		}
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ChannelsSSML), channels);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);

		return result;
	}
}
