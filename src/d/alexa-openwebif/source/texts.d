module texts;

import ask.locale;

///
static immutable AlexaText_de = mixin(LocaParser!(TextId, import("lang_de.csv")));
///
static immutable AlexaText_en = mixin(LocaParser!(TextId, import("lang_en.csv")));

///
enum TextId
{
	PleaseLogin,
	PleaseLoginSSML,
	DefaultCardTitle,
	HelloCardContent,
	HelloSSML,
	ChannelsCardTitle,
	ChannelsSSML,
	AboutCardTitle,
	AboutCardContent,
	AboutSSML,
	MoviesCardTitle,
	MoviesSSML,
	MuteCardTitle,
	MutedSSML,
	MuteFailedSSML,
	UnMutedSSML,
	StandbyCardTitle,
	StandbyFailedSSML,
	StandbySSML,
	BoxStartedSSML,
	SetVolumeCardTitle,
	SetVolumeFailedSSML,
	SetVolumeSSML,
	RecordNowCardTitle,
	RecordNowFailedSSML,
	RecordNowSSML,
	ZapToCardTitle,
	ZapUpCardTitle,
	ZapDownCardTitle,
	ZapRandomCardTitle,
	ZapToEventCardTitle,
	ZapToEventFailedSSML,
	ZapToEventNotFoundSSML,
	ZapFailedSSML,
	ZapSSML,
	ZapUp,
	ZapDown,
	ZapToRandom,
	SleepTimerCardTitle,
	SleepTimerOffSSML,
	SleepTimerResetSSML,
	SleepTimerSetSSML,
	SleepTimerFailedSSML,
	SleepTimerNoTimerSSML,
	CurrentCardTitle,
	CurrentSSML,
	CurrentNextSSML,
	RCPlayPauseCardTitle,
	RCOKSSML,
	RCFailedSSML,
	RCStopCardTitle,
	NotSupportedSSML,
	RCPreviousCardTitle,
	ErrorCardTitle,
	ErrorCardContent,
	ErrorSSML,
	SetVolumeRangeErrorSSML
}
