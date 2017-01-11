module lang.lang_en;

import lang.types;

///
enum AlexaText[] AlexaText_en = [
	AlexaText(TextId.PleaseLogin,"Please login"),
	AlexaText(TextId.PleaseLoginSSML,"<speak>Please use your Alexa app to log in</speak>"),
	AlexaText(TextId.DefaultCardTitle,"Telly"),
	AlexaText(TextId.HelloCardContent,"Telly says hello to %s"),
	AlexaText(TextId.HelloSSML,"<speak>Hello %s, thanks for logging in. What can I do for you?</speak>"),
	AlexaText(TextId.ChannelsCardTitle,"Channels"),
	AlexaText(TextId.ChannelsCardContent,"Channels"),
	AlexaText(TextId.ChannelsSSML,"<speak>You've got the following channels %s</speak>"),
	AlexaText(TextId.AboutCardTitle,"Telly Info"),
	AlexaText(TextId.AboutCardContent,"Telly Info"),
	AlexaText(TextId.AboutSSML,"<speak>"~
			"I am Telly, a alexa skill written in D. " ~
			"Stephan aka extrawurst and Fabian aka fabsi88 are my authors. " ~
			"Visit github for more information." ~
			"</speak>"),
	AlexaText(TextId.MoviesCardTitle,"Movie list"),
	AlexaText(TextId.MoviesCardContent,"Movie list"),
	AlexaText(TextId.MoviesSSML,"<speak>You've got the following movies %s</speak>"),
	AlexaText(TextId.MuteCardTitle,"Mute"),
	AlexaText(TextId.MuteCardContent,"Mute"),
	AlexaText(TextId.MutedSSML,"<speak>Muted</speak>"),
	AlexaText(TextId.MuteFailedSSML,"<speak>Mute failed</speak>"),
	AlexaText(TextId.UnMutedSSML,"<speak>Unmuted</speak>"),
	AlexaText(TextId.StandbyCardTitle,"Standby"),
	AlexaText(TextId.StandbyCardContent,"Standby"),
	AlexaText(TextId.StandbyFailedSSML,"<speak>Switch to standby failed</speak>"),
	AlexaText(TextId.StandbySSML,"<speak>Switched box to standby</speak>"),
	AlexaText(TextId.BoxStartedSSML,"<speak>Box started</speak>"),
	AlexaText(TextId.SetVolumeCardTitle, "Set volume"),
	AlexaText(TextId.SetVolumeCardContent, "Set volume"),
	AlexaText(TextId.SetVolumeFailedSSML,"<speak>Set volume failed</speak>"),
	AlexaText(TextId.SetVolumeSSML,"<speak>Set volume to %s</speak>"),
	AlexaText(TextId.RecordNowCardTitle,"Record now"),
	AlexaText(TextId.RecordNowCardContent,"Record now"),
	AlexaText(TextId.RecordNowFailedSSML,"<speak>Starting record failed</speak>"),
	AlexaText(TextId.RecordNowSSML,"<speak>Record started</speak>"),
	AlexaText(TextId.ZapToCardTitle,"Switch channel"),
	AlexaText(TextId.ZapToCardContent,"Switch channel"),
	AlexaText(TextId.ZapUpCardTitle,"Zap up"),
	AlexaText(TextId.ZapUpCardContent,"Zap up"),
	AlexaText(TextId.ZapDownCardTitle,"Zap down"),
	AlexaText(TextId.ZapDownCardContent,"Zap down"),
	AlexaText(TextId.ZapRandomCardTitle,"Switch to random channel"),
	AlexaText(TextId.ZapRandomCardContent,"Switch to random channel"),
	AlexaText(TextId.ZapFailedSSML,"none"),
	AlexaText(TextId.ZapSSML,"<speak>I've switched channel to <p>%s</p></speak>"),
	AlexaText(TextId.ZapUp,"up"),
	AlexaText(TextId.ZapDown,"down"),
	AlexaText(TextId.ZapToRandom,"random"),
	AlexaText(TextId.SleepTimerCardTitle,"Sleep Timer"),
	AlexaText(TextId.SleepTimerCardContent,"Sleep Timer"),
	AlexaText(TextId.SleepTimerOffSSML,"<speak>Sleep Timer switched off</speak>"),
	AlexaText(TextId.SleepTimerResetSSML,"<speak>There is sleep timer set with <p>%s minutes remaining."~
							"I've reset the sleep timer to %s minutes</p></speak>"),
	AlexaText(TextId.SleepTimerSetSSML,"<speak>I've set the sleepp timer to <p>%s minutes</p></speak>"),
	AlexaText(TextId.SleepTimerFailedSSML,"<speak>Set sleep timer failed</speak>"),
	AlexaText(TextId.SleepTimerNoTimerSSML,"<speak>No sleep timer found</speak>"),
	AlexaText(TextId.CurrentCardTitle,"You're watching"),
	AlexaText(TextId.CurrentCardContent,"You're watching"),
	AlexaText(TextId.CurrentSSML,"<speak>You are on: <p>%s" ~
			"</p>and watching:<p>%s</p></speak>"),
	AlexaText(TextId.CurrentNextSSML,"%s <p>%s</p> comes up next</speak>"),

];
