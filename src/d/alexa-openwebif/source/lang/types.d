module lang.types;

///
enum TextId
{
	PleaseLogin,
	PleaseLoginSSML,
	DefaultCardTitle,
	HelloCardContent,
	HelloSSML,
	ChannelsCardTitle,
	ChannelsCardContent,
	ChannelsSSML,
	AboutCardTitle,
	AboutCardContent,
	AboutSSML,
	MoviesCardTitle,
	MoviesCardContent,
	MoviesSSML,
	MuteCardTitle,
	MuteCardContent,
	MutedSSML,
	MuteFailedSSML,
	UnMutedSSML,
	StandbyCardTitle,
	StandbyCardContent,
	StandbyFailedSSML,
	StandbySSML,
	BoxStartedSSML,
	SetVolumeCardTitle,
	SetVolumeCardContent,
	SetVolumeFailedSSML,
	SetVolumeSSML,
	RecordNowCardTitle,
	RecordNowCardContent,
	RecordNowFailedSSML,
	RecordNowSSML,
	ZapToCardTitle,
	ZapToCardContent,
	ZapUpCardTitle,
	ZapUpCardContent,
	ZapDownCardTitle,
	ZapDownCardContent,
	ZapRandomCardTitle,
	ZapRandomCardContent,
	ZapFailedSSML,
	ZapSSML,
	ZapUp,
	ZapDown,
	ZapToRandom,
	SleepTimerCardTitle,
	SleepTimerCardContent,
	SleepTimerOffSSML,
	SleepTimerResetSSML,
	SleepTimerSetSSML,
	SleepTimerFailedSSML,
	SleepTimerNoTimerSSML,
	CurrentCardTitle,
	CurrentCardContent,
	CurrentSSML,
	CurrentNextSSML
}

enum foo = "PleaseLogin, foo\n CurrentNextSSML ,  bar  ";

enum AlexaText[] AlexaText_test = mixin(LocaParser!(TextId,foo));
static assert(AlexaText_test[0].text == "foo");
static assert(AlexaText_test[1].text == "bar");

///
enum AlexaText_de = mixin(LocaParser!(TextId,import("lang_de.csv")));
///
enum AlexaText_en = mixin(LocaParser!(TextId,import("lang_en.csv")));

unittest
{
	import std.stdio;
	//writefln("%s",AlexaText_test);
}

///
string LocaParser(E,string input)()
{
	import std.string:splitLines,strip;
	import std.algorithm:startsWith;
	import std.format:format;
	import std.array:split;

	enum string[] lines = input.splitLines;

	string res = "[";

	allMembers:
	foreach(enumMember; __traits(allMembers, E))
	{
		foreach(line; lines)
		{
			line = line.strip;

			if(line.startsWith(enumMember))
			{
				auto lineArgs = line.split(",");
				auto locaKey = lineArgs[0];
				auto locaText = line[locaKey.length+1..$].strip;
				auto entry = format("AlexaText(%s.%s, \"%s\"),", E.stringof,enumMember,locaText);
				res ~= entry ~ "\n";
				continue allMembers;
			}
		}
	}

	return res ~ "]";
}


///
struct AlexaText
{
	///
	int key;
	///
	string text;
}
