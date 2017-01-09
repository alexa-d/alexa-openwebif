import std.stdio;
import std.xml;
import std.string;

import vibe.d;
import ask.ask;

import skill;

int main(string[] args)
{
	import std.process:environment;
	immutable baseUrl = environment["OPENWEBIF_URL"];

	if(args.length != 4)
		return -1;

	immutable testingMode = args[1] == "true";

	string eventParamStr = args[2];
	string contextParamStr = args[3];

	if(!testingMode)
	{
		import std.base64:Base64;
		eventParamStr = cast(string)Base64.decode(eventParamStr);
		contextParamStr = cast(string)Base64.decode(contextParamStr);
	}

	auto eventJson = parseJson(eventParamStr);
	auto contextJson = parseJson(contextParamStr);

	AlexaEvent event;
	try{
		event = deserializeJson!AlexaEvent(eventJson);
	}
	catch(Exception e){
		stderr.writefln("could not deserialize event: %s",e);
	}

	AlexaContext context;
	try{
		context = deserializeJson!AlexaContext(contextJson);
	}
	catch(Exception e){
		stderr.writefln("could not deserialize context: %s",e);
	}

	auto skill = new OpenWebifSkill(baseUrl, event.request.locale);

	return skill.execute(event, context);
}
