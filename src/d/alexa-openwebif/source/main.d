import std.stdio;
import std.xml;
import std.string;

import vibe.d;
import ask.ask;

import skill;

///
int main(string[] args)
{
	import std.process:environment;
	import vibe.aws.aws;
	import vibe.aws.dynamodb;
	import std.conv:to;
	
	auto accessKey = environment["ACCESS_KEY"];
	auto secretKey = environment["SECRET_KEY"];
    auto awsRegion = environment["AWS_DYNAMODB_REGION"]; 
    auto owifTableName = environment["OPENWEBIF_TABLENAME"]; 
    auto creds = new StaticAWSCredentials(accessKey, secretKey); 
    auto ddb = new DynamoDB(awsRegion, creds); 
    auto table = ddb.table(owifTableName);
	
	
	

	if(args.length != 4)
	{
		stderr.writefln("expected 4 params, found: %s", args.length);
		return -1;
	}

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
	string baseUrl;
	try {
		auto password = "";
		auto user = "";
		auto item = table.get("accessToken", event.session.user.accessToken);
		if(("password" in item) !is null)
			password = to!string(item["password"]);	
		if(("username" in item) !is null)	
			user = to!string(item["username"]);			
		immutable url= to!string(item["url"]);
		auto urlSplit = url.split("://");
		auto protocol = urlSplit[0];
		auto host = urlSplit[1];

		baseUrl = format("%s://%s:%s@%s",protocol, user, password, host);

	} catch(Exception e)
	{
		stderr.writefln("%s has no entry in db: %s", event.session.user.accessToken, e);
	}
	
	AlexaContext context;
	try{
		context = deserializeJson!AlexaContext(contextJson);
	}
	catch(Exception e){
		stderr.writefln("could not deserialize context: %s",e);
	}

	auto skill = new OpenWebifSkill(baseUrl, event.request.locale);

	return skill.runInEventLoop(event, context);
}
