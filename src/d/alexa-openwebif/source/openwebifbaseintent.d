module openwebifbaseintent;

import openwebif.api;

import ask.ask;

import texts;

///
abstract class OpenWebifBaseIntent : BaseIntent
{
	protected OpenWebifApi apiClient;

	///
	this(OpenWebifApi api)
	{
		apiClient = api;
	}

	///
	protected AlexaResult returnError(Exception e)
	{
		import std.format : format;
		import std.random : uniform;
		import std.conv : to;
		import std.digest.crc : hexDigest, CRC32;
		import std.stdio : stderr;

		AlexaResult result;
		auto errorId = uniform!uint();
		auto errorHash = hexDigest!CRC32(to!string(errorId));
		stderr.writefln("Error: %s - Exception: %s", errorHash, e);
		result.response.card.title = getText(TextId.ErrorCardTitle);
		result.response.card.content = format(getText(TextId.ErrorCardContent), errorHash);
		result.response.outputSpeech.type = AlexaOutputSpeech.Type.SSML;
		result.response.outputSpeech.ssml = getText(TextId.ErrorSSML);
		return result;
	}

	///
	static ServicesList removeMarkers(ServicesList _list)
	{
		import std.algorithm : remove, endsWith;

		auto i = 0;
		while (i < _list.services[0].subservices.length)
		{
			if (_list.services[0].subservices[i].servicereference.endsWith(
					_list.services[0].subservices[i].servicename))
			{
				_list.services[0].subservices = remove(_list.services[0].subservices, i);
				continue;
			}
			i++;
		}
		return _list;
	}

	///
	static string removeTags(string _text)
	{
		import std.regex;
		auto pexpr = regex("<\\/p>");
		auto expr = regex("<[^>]*>");
		_text = _text.replaceAll(pexpr, "\n");
		return  _text.replaceAll(expr, "");
	}

	///
	unittest
	{
		auto text = "<speak>This is a test <p>text</p></speak>";
		assert (removeTags(text) == "This is a test text\n");
	}
}
