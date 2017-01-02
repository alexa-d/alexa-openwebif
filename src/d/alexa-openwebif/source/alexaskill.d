module alexaskill;

import vibe.d;

import ask.ask;

///
struct CustomIntent
{
  string name;
}

///
abstract class AlexaBaseSkill(T)
{
	///
	int execute(AlexaEvent event, AlexaContext context)
	{
		runTask({
			scope(exit) exitEventLoop();

			AlexaResult result;

			if(event.request.type == AlexaRequest.Type.LaunchRequest)
				result = onLaunch(event, context);
			else if(event.request.type == AlexaRequest.Type.IntentRequest)
				result = onIntent(event, context);
			else if(event.request.type == AlexaRequest.Type.SessionEndedRequest)
				onSessionEnd(event, context);

			import std.stdio:writeln;
			writeln(serializeToJson(result).toPrettyString());
		});

		return runEventLoop();
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#launchrequest
	AlexaResult onLaunch(AlexaEvent event, AlexaContext context)
	{
		throw new Exception("not implemented");
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#intentrequest
	AlexaResult onIntent(AlexaEvent event, AlexaContext context)
	{
		import std.traits:hasUDA,getUDAs;

		foreach(i, member; __traits(allMembers, T))
		{
			static if(hasUDA!(__traits(getMember, T, member), CustomIntent))
			{
				enum name = getUDAs!(__traits(getMember, T, member), CustomIntent)[0].name;
				
				if(event.request.intent.name == name)
				{
					mixin("return (cast(T)this)."~member~"(event, context);");
				}
			}
		}

		return AlexaResult();
	}

	/// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/custom-standard-request-types-reference#sessionendedrequest
	void onSessionEnd(AlexaEvent event, AlexaContext context)
	{
		throw new Exception("not implemented");
	}
}
