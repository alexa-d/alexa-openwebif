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
struct ServiceAlias
{
	///
	string serviceName;
	///
	string aliasName;
}

//TODO: support english aliases
///
static immutable ServiceAliases = [
	ServiceAlias("Das Erste HD", "ard"), ServiceAlias("Das Erste HD", "das erste"), ServiceAlias("Das Erste HD",
		"a. r. d."), 
	ServiceAlias("WDR HD", "w. d. r."), ServiceAlias("WDR HD", "wdr"), 
	ServiceAlias("WDR Essen", "w. d. r. essen"), ServiceAlias("WDR Essen", "wdr essen"),
	ServiceAlias("WDR Duisburg", "w. d. r. duisburg"), ServiceAlias("WDR Duisburg", "wdr duisburg"),  
	ServiceAlias("WDR Bonn", "w. d. r. bonn"), ServiceAlias("WDR Bonn", "wdr bonn"),  
	ServiceAlias("WDR Bielefeld", "w. d. r. bielefeld"), ServiceAlias("WDR bielefeld", "wdr bielefeld"),  
	ServiceAlias("WDR Münster", "w. d. r. münster"), ServiceAlias("WDR Münster", "wdr münster"), 
	ServiceAlias("WDR Düsseldorf", "w. d. r. düsseldorf"), ServiceAlias("WDR Düsseldorf", "wdr düsseldorf"),    
	ServiceAlias("WDR Aachen", "w. d. r. aachen"), ServiceAlias("WDR Aachen", "wdr aachen"),  
	ServiceAlias("WDR Siegen", "w. d. r. Siegen"), ServiceAlias("WDR Siegen", "wdr siegen"),  
	ServiceAlias("WDR wuppertal", "w. d. r. wuppertal"), ServiceAlias("WDR Wuppertal", "wdr wuppertal"),  
	ServiceAlias("WDR Köln", "w. d. r. köln"), ServiceAlias("WDR Köln", "wdr köln"),  
		ServiceAlias("WDR Köln HD", "w. d. r. köln hd"), ServiceAlias("WDR Köln HD", "wdr Köln HD"),
	ServiceAlias("n-tv", "n. t. v."), ServiceAlias("n-tv", "ntv"),
	ServiceAlias("RTL television", "r. t. l."), ServiceAlias("RTL Television", "rtl"),
	ServiceAlias("Super RTL", "super r. t. l."),       
	ServiceAlias("NDR", "n. d. r."),
	ServiceAlias("N24", "n. 24"),
	ServiceAlias("MTV", "m. t. v."),
	ServiceAlias("MGM", "m. g. m."),
	ServiceAlias("ARD Alpha", "a. r. d. alpha"), ServiceAlias("ARD Alpha", "ard alpha"),  
	ServiceAlias("ZDF HD", "z. d. f."), ServiceAlias("ZDF HD", "zdf"),
	ServiceAlias("zdf_neo", "z. d. f. neo"), ServiceAlias("PHOENIX HD", "phönix"),
	ServiceAlias("QVC", "q. v. c."), 
];

///
static Subservice zapTo(string _channel, ServicesList _allservices)
{
	ulong distAlias, distService;
	size_t idxAlias, idxService;

	matchAlias(_channel, ServiceAliases, idxAlias, distAlias);
	matchServiceName(_channel, _allservices.services[0].subservices, idxService, distService);

	if (distAlias < distService)
	{
		matchServiceName(ServiceAliases[idxAlias].serviceName,
				_allservices.services[0].subservices, idxService, distService);
	}

	return _allservices.services[0].subservices[idxService];
}

//TODO: unify this with matchAlias
///
static void matchServiceName(string name, in Subservice[] services, ref size_t idx,
		ref ulong distance)
{
	import std.algorithm.searching : startsWith;

	distance = ulong.max;
	idx = 0;

	foreach (i, subservice; services)
	{
		if (subservice.servicename.length < 2)
			continue;

		if (subservice.servicename.startsWith(name) || name.startsWith(subservice.servicename))
		{
			distance = 0;
			idx = i;
			continue;
		}

		import std.algorithm : levenshteinDistance;

		immutable dist = levenshteinDistance(subservice.servicename, name);
		if (dist < distance)
		{
			distance = dist;
			idx = i;
		}
	}
}

///
private static void matchAlias(string name, in ServiceAlias[] aliases,
		ref size_t idx, ref ulong distance)
{
	distance = ulong.max;
	idx = 0;

	foreach (i, thisalias; aliases)
	{
		import std.algorithm : levenshteinDistance;

		immutable dist = levenshteinDistance(thisalias.aliasName, name);
		if (dist < distance)
		{
			distance = dist;
			idx = i;
		}
	}
}

///
unittest
{
	size_t idx;
	ulong dist;

	static immutable aliases = [
		ServiceAlias("foo", "bar"), ServiceAlias("das erste", "ARD"),
		ServiceAlias("das erste hd", "das erste"),
	];

	matchAlias("ARD", aliases, idx, dist);
	assert(idx == 1);

	matchAlias("bar", aliases, idx, dist);
	assert(idx == 0);

	matchAlias("erste", aliases, idx, dist);
	assert(idx == 2);
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
