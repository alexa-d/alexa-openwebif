module intents.zap;

import openwebif.api;

import ask.ask;

import texts;
import skill;

///
final class IntentZapTo : BaseIntent
{
	private OpenWebifApi apiClient;

	///
	this(OpenWebifApi api)
	{
		apiClient = api;
	}

	///
	override AlexaResult onIntent(AlexaEvent event, AlexaContext)
	{
		import std.format : format;

		auto targetChannel = event.request.intent.slots["targetChannel"].value;
		Subservice matchedServices;
		auto switchedTo = getText(TextId.ZapFailedSSML);

		if (targetChannel.length > 0)
		{
			auto allservices = removeMarkers(apiClient.getallservices());
			matchedServices = zapTo(targetChannel, allservices);
		}

		if (matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapToCardTitle);
		result.response.card.content = getText(TextId.ZapToCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);

		return result;
	}
}

///
final class IntentZapUp : BaseIntent
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
		auto result = doZapIntent(true, apiClient, this);
		result.response.card.title = getText(TextId.ZapUpCardTitle);
		result.response.card.content = getText(TextId.ZapUpCardContent);

		return result;
	}
}

///
final class IntentZapDown : BaseIntent
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
		auto result = doZapIntent(false, apiClient, this);
		result.response.card.title = getText(TextId.ZapDownCardTitle);
		result.response.card.content = getText(TextId.ZapDownCardContent);

		return result;
	}
}

///
final class IntentZapRandom : BaseIntent
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
		import std.format : format;

		Subservice matchedServices;

		auto switchedTo = getText(TextId.ZapFailedSSML);
		auto allservices = removeMarkers(apiClient.getallservices());
		matchedServices = zapRandom(allservices);
		if (matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapRandomCardTitle);
		result.response.card.content = getText(TextId.ZapRandomCardContent);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);

		return result;
	}
}

///
static AlexaResult doZapIntent(bool up, OpenWebifApi apiClient, ITextManager texts)
{
	import std.format : format;

	Subservice matchedServices;

	auto switchedTo = texts.getText(TextId.ZapFailedSSML);
	auto allservices = removeMarkers(apiClient.getallservices());
	matchedServices = zapUpDown(up, apiClient, allservices);
	if (matchedServices.servicereference.length > 0)
	{
		apiClient.zap(matchedServices.servicereference);
		switchedTo = matchedServices.servicename;
	}
	AlexaResult result;

	result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
	result.response.outputSpeech.ssml = format(texts.getText(TextId.ZapSSML), switchedTo);

	return result;
}

///
static Subservice zapRandom(ServicesList _allservices)
{
	import std.random : uniform;

	if (_allservices.services[0].subservices.length > 0)
	{
		auto i = uniform(0, _allservices.services[0].subservices.length - 1);
		return _allservices.services[0].subservices[i];
	}
	Subservice _ret;
	return _ret;

}

///
static Subservice zapTo(string _channel, ServicesList _allservices)
{
	ulong minDistance = ulong.max;
	size_t minIndex;
	foreach (i, subservice; _allservices.services[0].subservices)
	{
		if (subservice.servicename.length < 2)
			continue;

		import std.algorithm : levenshteinDistance;

		auto dist = levenshteinDistance(subservice.servicename, _channel);
		if (dist < minDistance)
		{
			minDistance = dist;
			minIndex = i;
		}
	}
	return _allservices.services[0].subservices[minIndex];
}

///
static Subservice zapUpDown(bool up, OpenWebifApi apiClient, ServicesList _allservices)
{
	immutable currentservice = apiClient.getcurrent();

	import std.algorithm.searching : countUntil;

	static bool pred(Subservice subs, CurrentService curr)
	{
		return curr.info._ref == subs.servicereference;
	}

	immutable index = cast(int) countUntil!(pred)(_allservices.services[0].subservices,
			currentservice);

	auto j = 0;

	if (up)
		j = index + 1;
	else
		j = index - 1;

	immutable maxIndex = cast(int) _allservices.services[0].subservices.length;

	// handle end or beginning of servicelist
	if (j >= maxIndex)
		j = 0;
	else if (j < 0)
		j = maxIndex - 1;

	return _allservices.services[0].subservices[j];
}
