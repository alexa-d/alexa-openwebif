module intents.zap;

import openwebif.api;

import ask.ask;

import texts;

import openwebifbaseintent;

///
abstract class ZapBaseIntent : OpenWebifBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	protected AlexaResult doZapIntent(bool up, OpenWebifApi apiClient, AlexaResult result)
	{
		import std.format : format;

		Subservice matchedServices;
		ServicesList allservices;

		auto switchedTo = getText(TextId.ZapFailedSSML);
		try
			allservices = removeMarkers(apiClient.getallservices());
		catch (Exception e)
			return returnError(e);

		matchedServices = zapUpDown(up, apiClient, allservices);
		if (matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}

		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}

///
final class IntentZapTo : ZapBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
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
			ServicesList allservices;
			try
				allservices = removeMarkers(apiClient.getallservices());
			catch (Exception e)
				return returnError(e);

			matchedServices = zapTo(targetChannel, allservices);
		}

		if (matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}

		AlexaResult result;
		result.response.card.title = getText(TextId.ZapToCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);

		return result;
	}
}

///
final class IntentZapUp : ZapBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapUpCardTitle);
		return doZapIntent(true, apiClient, result);
	}
}

///
final class IntentZapDown : ZapBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent, AlexaContext)
	{
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapDownCardTitle);
		return doZapIntent(false, apiClient, result);
	}
}

///
final class IntentZapRandom : ZapBaseIntent
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

		Subservice matchedServices;

		ServicesList allservices;

		auto switchedTo = getText(TextId.ZapFailedSSML);
		try
			allservices = removeMarkers(apiClient.getallservices());
		catch (Exception e)
			return returnError(e);

		matchedServices = zapRandom(allservices);
		if (matchedServices.servicereference.length > 0)
		{
			apiClient.zap(matchedServices.servicereference);
			switchedTo = matchedServices.servicename;
		}
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapRandomCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);
		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
}

///
final class IntentZapToEvent : ZapBaseIntent
{
	///
	this(OpenWebifApi api)
	{
		super(api);
	}

	///
	override AlexaResult onIntent(AlexaEvent event, AlexaContext)
	{
		import std.format : format;
		import std.stdio : writeln;

		auto targetEvent = event.request.intent.slots["targetEvent"].value;
		auto switchedTo = getText(TextId.ZapFailedSSML);

		EPGSearchList eventList;
		AlexaResult result;
		result.response.card.title = getText(TextId.ZapToEventCardTitle);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;

		try
			eventList = apiClient.epgsearch(targetEvent);
		catch (Exception e)
			return returnError(e);

		if (eventList.events.length == 0)
		{
			result.response.outputSpeech.ssml = getText(TextId.ZapToEventNotFoundSSML);
			result.response.card.content = removeTags(result.response.outputSpeech.ssml);
			return result;
		}

		import std.algorithm : sort;
		import std.datetime : Clock;
		import core.stdc.time : time, time_t;

		immutable now = time(null);
		auto sortedEventList = eventList.events.sort!((a,
				b) => a.begin_timestamp < b.begin_timestamp);
		auto idx = 0;
		auto idxnext = -1;
		foreach (thisEvent; sortedEventList)
		{
			if ((thisEvent.begin_timestamp > now) && idxnext == -1)
				idxnext = idx;
			if (thisEvent.begin_timestamp <= now
					&& (thisEvent.begin_timestamp + thisEvent.duration_sec) > now)
				break;
			idx++;
		}

		if (idx < sortedEventList.length)
		{
			apiClient.zap(sortedEventList[idx].sref);
			switchedTo = sortedEventList[idx].sname;
			result.response.outputSpeech.ssml = format(getText(TextId.ZapSSML), switchedTo);
		}
		else
		{
			auto ev = sortedEventList[idxnext];
			result.response.outputSpeech.ssml = format(getText(TextId.ZapToEventFailedSSML),
					ev.title, ev.begin, ev.sname);
		}

		result.response.card.content = removeTags(result.response.outputSpeech.ssml);
		return result;
	}
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
	ServiceAlias("Das Erste", "ard"), ServiceAlias("Das Erste", "a. r. d."), ServiceAlias("Das Erste HD",
		"a. r. d. h. d."), ServiceAlias("Das Erste HD", "ard hd"), ServiceAlias("WDR HD", "w. d. r. h. d."),
	ServiceAlias("WDR HD", "wdr hd"), ServiceAlias("WDR", "w. d. r."),
	ServiceAlias("WDR", "wdr"), ServiceAlias("WDR Essen",
		"w. d. r. essen"), ServiceAlias("WDR Essen", "wdr essen"),
	ServiceAlias("WDR Duisburg", "w. d. r. duisburg"), ServiceAlias(
		"WDR Duisburg", "wdr duisburg"), ServiceAlias("WDR Bonn",
		"w. d. r. bonn"), ServiceAlias("WDR Bonn", "wdr bonn"),
	ServiceAlias("WDR Bielefeld",
		"w. d. r. bielefeld"), ServiceAlias("WDR bielefeld", "wdr bielefeld"),
	ServiceAlias("WDR Münster", "w. d. r. münster"),
	ServiceAlias("WDR Münster",
		"wdr münster"), ServiceAlias("WDR Düsseldorf", "w. d. r. düsseldorf"),
	ServiceAlias("WDR Düsseldorf", "wdr düsseldorf"),
	ServiceAlias("WDR Aachen", "w. d. r. aachen"),
	ServiceAlias("WDR Aachen", "wdr aachen"), ServiceAlias("WDR Siegen",
		"w. d. r. Siegen"), ServiceAlias("WDR Siegen", "wdr siegen"),
	ServiceAlias("WDR wuppertal", "w. d. r. wuppertal"),
	ServiceAlias("WDR Wuppertal", "wdr wuppertal"), ServiceAlias("WDR Köln",
		"w. d. r. köln"), ServiceAlias("WDR Köln", "wdr köln"),
	ServiceAlias("WDR Köln HD", "w. d. r. köln h. d."),
	ServiceAlias("WDR Köln HD", "wdr Köln HD"), ServiceAlias("n-tv",
		"n. t. v."), ServiceAlias("n-tv", "ntv"), ServiceAlias("n-tv HD",
		"n. t. v. h. d."), ServiceAlias("n-tv HD", "ntv hd"),
	ServiceAlias("RTL television", "r. t. l."), ServiceAlias("RTL Television",
		"rtl"), ServiceAlias("RTL television HD", "r. t. l. h. d."),
	ServiceAlias("RTL Television", "rtl hd"), ServiceAlias("RTL2",
		"r. t. l. zwei"), ServiceAlias("RTL2", "rtl zwei"), ServiceAlias("RTL2 HD",
		"r. t. l. zwei h. d."), ServiceAlias("RTL2 HD",
		"rtl zwei hd"), ServiceAlias("Super RTL", "super r. t. l."),
	ServiceAlias("Super RTL HD", "super r. t. l. h. d."),
	ServiceAlias("NDR", "n. d. r."), ServiceAlias("N24", "n. 24"),
	ServiceAlias("N24", "n. vierundzwanzig"), ServiceAlias("N24 HD",
		"n. 24 h. d."), ServiceAlias("N24 HD", "n. vierundzwanzig h. d."),
	ServiceAlias("MTV", "m. t. v."), ServiceAlias("MTV HD",
		"m. t. v. h. d."), ServiceAlias("MGM", "m. g. m."),
	ServiceAlias("ARD Alpha", "a. r. d. alpha"), ServiceAlias("ARD Alpha",
		"ard alpha"), ServiceAlias("ZDF HD", "z. d. f."),
	ServiceAlias("ZDF HD", "z. d. f. h. d."), ServiceAlias("zdf_neo",
		"z. d. f. neo"), ServiceAlias("PHOENIX HD", "phönix"), ServiceAlias("QVC",
		"q. v. c."), ServiceAlias("Sky Sport Bundesliga 1 HD",
		"Sky Bundesliga 1 h. d."),
	ServiceAlias("Sky Sport Bundesliga 2 HD",
		"Sky Bundesliga 2 h. d."), ServiceAlias("Sky Sport Bundesliga 3 HD",
		"Sky Bundesliga 3 h. d."), ServiceAlias("Sky Sport Bundesliga 4 HD",
		"Sky Bundesliga 4 h. d."), ServiceAlias(
		"Sky Sport Bundesliga 5 HD", "Sky Bundesliga 5 h. d."), ServiceAlias(
		"Sky Sport Bundesliga 6 HD", "Sky Bundesliga 6 h. d."),
	ServiceAlias("Sky Sport Bundesliga 7 HD", "Sky Bundesliga 7 h. d."),
	ServiceAlias("Sky Sport Bundesliga 8 HD", "Sky Bundesliga 8 h. d."),
	ServiceAlias("Sky Sport Bundesliga 9 HD",
		"Sky Bundesliga 9 h. d."),
	ServiceAlias("Sky Sport Bundesliga 10 HD",
		"Sky Bundesliga 10 h. d."), ServiceAlias("Sky Sport Bundesliga 1 HD",
		"Sky Bundesliga eins h. d."), ServiceAlias("Sky Sport Bundesliga 2 HD",
		"Sky Bundesliga zwei h. d."), ServiceAlias(
		"Sky Sport Bundesliga 3 HD", "Sky Bundesliga drei h. d."), ServiceAlias(
		"Sky Sport Bundesliga 4 HD", "Sky Bundesliga vier h. d."),
	ServiceAlias("Sky Sport Bundesliga 5 HD", "Sky Bundesliga fünf h. d."),
	ServiceAlias("Sky Sport Bundesliga 6 HD", "Sky Bundesliga sechs h. d."),
	ServiceAlias("Sky Sport Bundesliga 7 HD",
		"Sky Bundesliga sieben h. d."),
	ServiceAlias("Sky Sport Bundesliga 8 HD",
		"Sky Bundesliga acht h. d."), ServiceAlias("Sky Sport Bundesliga 9 HD",
		"Sky Bundesliga neun h. d."), ServiceAlias("Sky Sport Bundesliga 10 HD",
		"Sky Bundesliga zehn h. d."),
	ServiceAlias("Sky Sport Bundesliga 1 HD",
		"Sky Sport Bundesliga 1 h. d."),
	ServiceAlias("Sky Sport Bundesliga 2 HD",
		"Sky Sport Bundesliga 2 h. d."), ServiceAlias("Sky Sport Bundesliga 3 HD",
		"Sky Sport Bundesliga 3 h. d."), ServiceAlias("Sky Sport Bundesliga 4 HD",
		"Sky Sport Bundesliga 4 h. d."),
	ServiceAlias("Sky Sport Bundesliga 5 HD",
		"Sky Sport Bundesliga 5 h. d."),
	ServiceAlias("Sky Sport Bundesliga 6 HD",
		"Sky Sport Bundesliga 6 h. d."), ServiceAlias("Sky Sport Bundesliga 7 HD",
		"Sky Sport Bundesliga 7 h. d."), ServiceAlias("Sky Sport Bundesliga 8 HD",
		"Sky Sport Bundesliga 8 h. d."),
	ServiceAlias("Sky Sport Bundesliga 9 HD",
		"Sky Sport Bundesliga 9 h. d."),
	ServiceAlias("Sky Sport Bundesliga 10 HD",
		"Sky Sport Bundesliga 10 h. d."), ServiceAlias("Sky Sport Bundesliga 1 HD",
		"Sky Sport Bundesliga eins h. d."),
	ServiceAlias("Sky Sport Bundesliga 2 HD", "Sky Sport Bundesliga zwei h. d."),
	ServiceAlias("Sky Sport Bundesliga 3 HD",
		"Sky Sport Bundesliga drei h. d."),
	ServiceAlias("Sky Sport Bundesliga 4 HD",
		"Sky Sport Bundesliga vier h. d."), ServiceAlias("Sky Sport Bundesliga 5 HD",
		"Sky Sport Bundesliga fünf h. d."),
	ServiceAlias("Sky Sport Bundesliga 6 HD", "Sky Sport Bundesliga sechs h. d."),
	ServiceAlias("Sky Sport Bundesliga 7 HD",
		"Sky Sport Bundesliga sieben h. d."),
	ServiceAlias("Sky Sport Bundesliga 8 HD",
		"Sky Sport Bundesliga acht h. d."), ServiceAlias("Sky Sport Bundesliga 9 HD",
		"Sky Sport Bundesliga neun h. d."),
	ServiceAlias("Sky Sport Bundesliga 10 HD", "Sky Sport Bundesliga zehn h. d."),
	ServiceAlias("Sky Sport Bundesliga 1",
		"Sky Sport Bundesliga eins"),
	ServiceAlias("Sky Sport Bundesliga 2",
		"Sky Sport Bundesliga zwei"), ServiceAlias("Sky Sport Bundesliga 3",
		"Sky Sport Bundesliga drei"), ServiceAlias("Sky Sport Bundesliga 4",
		"Sky Sport Bundesliga vier"), ServiceAlias(
		"Sky Sport Bundesliga 5", "Sky Sport Bundesliga fünf"), ServiceAlias(
		"Sky Sport Bundesliga 6", "Sky Sport Bundesliga sechs"),
	ServiceAlias("Sky Sport Bundesliga 7", "Sky Sport Bundesliga sieben"),
	ServiceAlias("Sky Sport Bundesliga 8", "Sky Sport Bundesliga acht"),
	ServiceAlias("Sky Sport Bundesliga 9",
		"Sky Sport Bundesliga neun"), ServiceAlias("Sky Sport Bundesliga 10",
		"Sky Sport Bundesliga zehn"), ServiceAlias("Sky Sport 1 HD",
		"Sky Sport 1 h. d."), ServiceAlias("Sky Sport 2 HD", "Sky Sport 2 h. d."),
	ServiceAlias("Sky Sport 3 HD",
		"Sky Sport 3 h. d."), ServiceAlias("Sky Sport 4 HD", "Sky Sport 4 h. d."),
	ServiceAlias("Sky Sport 5 HD", "Sky Sport 5 h. d."),
	ServiceAlias("Sky Sport 6 HD",
		"Sky Sport 6 h. d."), ServiceAlias("Sky Sport 7 HD", "Sky Sport 7 h. d."),
	ServiceAlias("Sky Sport 8 HD", "Sky Sport 8 h. d."),
	ServiceAlias("Sky Sport 9 HD",
		"Sky Sport 9 h. d."), ServiceAlias("Sky Sport 10 HD", "Sky Sport 10 h. d."),
	ServiceAlias("Sky Sport 1 HD", "Sky Sport eins h. d."),
	ServiceAlias("Sky Sport 2 HD",
		"Sky Sport zwei h. d."), ServiceAlias("Sky Sport 3 HD",
		"Sky Sport drei h. d."), ServiceAlias("Sky Sport 4 HD", "Sky Sport vier h. d."),
	ServiceAlias("Sky Sport 5 HD", "Sky Sport fünf h. d."),
	ServiceAlias("Sky Sport 6 HD",
		"Sky Sport sechs h. d."), ServiceAlias("Sky Sport 7 HD",
		"Sky Sport sieben h. d."), ServiceAlias("Sky Sport 8 HD", "Sky Sport acht h. d."),
	ServiceAlias("Sky Sport 9 HD", "Sky Sport neun h. d."),
	ServiceAlias("Sky Sport 10 HD",
		"Sky Sport zehn h. d."), ServiceAlias("Sky Sport 1", "Sky Sport eins"),
	ServiceAlias("Sky Sport 2", "Sky Sport zwei"),
	ServiceAlias("Sky Sport 3",
		"Sky Sport drei"), ServiceAlias("Sky Sport 4", "Sky Sport vier"),
	ServiceAlias("Sky Sport 5", "Sky Sport fünf"),
	ServiceAlias("Sky Sport 6",
		"Sky Sport sechs"), ServiceAlias("Sky Sport 7", "Sky Sport sieben"),
	ServiceAlias("Sky Sport 8", "Sky Sport acht"),
	ServiceAlias("Sky Sport 9",
		"Sky Sport neun"), ServiceAlias("Sky Sport 10", "Sky Sport zehn"),
	ServiceAlias("Sky Cinema +1", "Sky Cinema plus eins"), ServiceAlias("Sky Cinema +1",
		"Sky Cinema + eins"), ServiceAlias("Sky Cinema +1 HD",
		"Sky Cinema plus eins h. d."), ServiceAlias("Sky Cinema +1 HD",
		"Sky Cinema + eins h. d."), ServiceAlias("Sky Cinema +24",
		"Sky Cinema plus vierundzwanzig"),
	ServiceAlias("Sky Cinema +24",
		"Sky Cinema + vierundzwanzig"),
	ServiceAlias("Sky Cinema HD", "Sky Cinema h. d."),
	ServiceAlias("Discovery Channel (S)", "Discovery Channel"),
	ServiceAlias("Discovery Channel", "Discovery Channel"),
	ServiceAlias("Discovery HD (S)",
		"Discovery Channel h. d."), ServiceAlias("Discovery HD (S)", "Discovery h. d."),
	ServiceAlias("Discovery HD", "Discovery Channel h. d."),
	ServiceAlias("Discovery HD",
		"Discovery h. d."), ServiceAlias("Disney Cinemagic HD",
		"Disney Cinemagic h. d."), ServiceAlias("Disney Junior (S)",
		"Disney Junior"), ServiceAlias("Disney Junior", "Disney Junior"),
	ServiceAlias("Disney XD (S)", "Disney x. d."),
	ServiceAlias("Disney XD", "Disney x. d."), ServiceAlias("Eurosport 1 HD",
		"Eurosport eins h. d."), ServiceAlias("Eurosport 1", "Eurosport eins"),
	ServiceAlias("Fox Serie (S)", "Fox Serie"), ServiceAlias("Fox Serie (S)",
		"Fox"), ServiceAlias("Fox Serie", "Fox Serie"),
	ServiceAlias("Fox Serie", "Fox"), ServiceAlias("Fox HD (S)", "Fox h. d."),
	ServiceAlias("Fox HD", "Fox h. d."), ServiceAlias("Nat Geo Wild HD",
		"Nat Geo Wild h. d."), ServiceAlias("Nat Geo Wild HD",
		"National geographic wild h. d."), ServiceAlias("Nat Geo Wild",
		"Nat Geo Wild"), ServiceAlias("Nat Geo Wild", "National geographic wild"),
	ServiceAlias("Nat Geo HD (S)",
		"Nat Geo h. d."), ServiceAlias("Nat Geo HD (S)", "National geographic h. d."),
	ServiceAlias("Nat Geo HD", "Nat Geo h. d."), ServiceAlias("Nat Geo HD",
		"National geographic h. d."), ServiceAlias("National Geographic (S)",
		"National Geographic"), ServiceAlias("National Geographic",
		"National Geographic"), ServiceAlias("RTL Crime (S)", "r. t. l. crime"),
	ServiceAlias("RTL Crime",
		"r. t. l. crime"), ServiceAlias("RTL Passion (S)", "r. t. l. passion"),
	ServiceAlias("RTL Passion", "r. t. l. passion"),
	ServiceAlias("Sky 1", "sky eins"), ServiceAlias("Sky 1 HD",
		"sky eins h. d."), ServiceAlias("Sky Atlantic HD", "Sky Atlantic h. d."),
	ServiceAlias("Sky Cinema Action HD", "Sky Cinema Action h. d."),
	ServiceAlias("Sky Cinema Hits HD",
		"Sky Cinema Hits h. d."), ServiceAlias("Sky Sport News HD",
		"Sky Sport News h. d."), ServiceAlias("TNT Serie (S)",
		"t. n. t. serie"), ServiceAlias("TNT Serie (S)", "t. n. t."),
	ServiceAlias("TNT Serie",
		"t. n. t. serie"), ServiceAlias("TNT Serie", "t. n. t."),
	ServiceAlias("TNT Serie HD (S)", "t. n. t. serie h. d."),
	ServiceAlias("TNT Serie HD (S)",
		"t. n. t. h. d."), ServiceAlias("TNT Serie HD", "t. n. t. serie h. d."),
	ServiceAlias("TNT Serie HD", "t. n. t. h. d."), ServiceAlias("ARD-alpha", "a. r. d. alpha"),

];
