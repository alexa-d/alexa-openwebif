import std.stdio;
import std.xml;
import std.string;

import vibe.d;
import ask.ask;

import skill;

///
int main(string[] args)
{
	if (args.length != 4)
	{
		stderr.writefln("expected 4 params, found: %s", args.length);
		return -1;
	}

	immutable testingMode = args[1] == "true";

	string eventParamStr = args[2];
	string contextParamStr = args[3];

	if (!testingMode)
	{
		import std.base64 : Base64;

		eventParamStr = cast(string) Base64.decode(eventParamStr);
		contextParamStr = cast(string) Base64.decode(contextParamStr);
	}

	auto eventJson = parseJson(eventParamStr);
	auto contextJson = parseJson(contextParamStr);

	AlexaEvent event;
	try
	{
		event = deserializeJson!AlexaEvent(eventJson);
	}
	catch (Exception e)
	{
		stderr.writefln("could not deserialize event: %s", e);
	}

	AlexaContext context;
	try
	{
		context = deserializeJson!AlexaContext(contextJson);
	}
	catch (Exception e)
	{
		stderr.writefln("could not deserialize context: %s", e);
	}

	import std.process : environment;

	immutable accessKey = environment["ACCESS_KEY"];
	immutable secretKey = environment["SECRET_KEY"];
	immutable awsRegion = environment["AWS_DYNAMODB_REGION"];
	immutable owifTableName = environment["OPENWEBIF_TABLENAME"];

	auto skill = new OpenWebifSkill(event.session.user.accessToken,
			event.request.locale, accessKey, secretKey, awsRegion, owifTableName);

	return skill.runInEventLoop(event, context);
}
