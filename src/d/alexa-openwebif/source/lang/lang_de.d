module lang.lang_de;

import lang.types;

///
enum AlexaText[] AlexaText_de = [
	AlexaText(TextId.PleaseLogin,"Bitte log dich ein"),
	AlexaText(TextId.PleaseLoginSSML,"<speak>Bitte log dich in deiner Alexa App ein</speak>"),
	AlexaText(TextId.DefaultCardTitle,"Telly"),
	AlexaText(TextId.HelloCardContent,"Telly sagt hallo zu %s"),
	AlexaText(TextId.HelloSSML,"<speak>Hallo %s, danke fürs einloggen. Was kann ich für dich tun?</speak>"),
	AlexaText(TextId.ChannelsCardTitle,"Kanäle"),
	AlexaText(TextId.ChannelsCardContent, "Kanäle"),
	AlexaText(TextId.ChannelsSSML,"<speak>Du hast die folgenden Kanäle %s</speak>"),
	AlexaText(TextId.AboutCardTitle,"Telly Info"),
	AlexaText(TextId.AboutCardContent,"Telly Info"),
	AlexaText(TextId.AboutSSML,"<speak>"~
			"Ich bin Telly, ein Alexa Skill geschrieben in D. " ~
			"Stephan aka extrawurst und Fabian aka fabsi88 sind meine Autoren. " ~
			"Finde mehr über mich heraus bei github." ~
			"</speak>"),
	AlexaText(TextId.MoviesCardTitle,"Filmliste"),
	AlexaText(TextId.MoviesCardContent,"Filmliste"),
	AlexaText(TextId.MoviesSSML,"<speak>Du hast die folgenden Filme %s</speak>"),
	AlexaText(TextId.MuteCardTitle,"Stummschalten"),
	AlexaText(TextId.MuteCardContent,"Stummschalten"),
	AlexaText(TextId.MutedSSML,"<speak>Stumm geschaltet</speak>"),
	AlexaText(TextId.MuteFailedSSML,"<speak>Stummschalten fehlgeschlagen</speak>"),
	AlexaText(TextId.UnMutedSSML,"<speak>Stummschalten abgeschaltet</speak>"),
	AlexaText(TextId.StandbyCardTitle,"Standby"),
	AlexaText(TextId.StandbyCardContent,"Stanby"),
	AlexaText(TextId.StandbyFailedSSML,"<speak>In Standby wechseln ist fehlgeschlagen</speak>"),
	AlexaText(TextId.StandbySSML,"<speak>Box in Standby geschaltet</speak>"),
	AlexaText(TextId.BoxStartedSSML,"<speak>Box gestartet</speak>"),	
	AlexaText(TextId.SetVolumeCardTitle, "Lautstärke anpassen"),
	AlexaText(TextId.SetVolumeCardContent, "Lautstärke anpassen"),
	AlexaText(TextId.SetVolumeFailedSSML,"<speak>Lautstärke anpassen fehlgeschlagen</speak>"),
	AlexaText(TextId.SetVolumeSSML,"<speak>Lautstärke auf %s gesetzt</speak>"),
	AlexaText(TextId.RecordNowCardTitle,"Aufnahme starten"),
	AlexaText(TextId.RecordNowCardContent,"Aufnahme starten"),
	AlexaText(TextId.RecordNowFailedSSML,"<speak>Aufnhame starten fehlgeschlagen</speak>"),
	AlexaText(TextId.RecordNowSSML,"<speak>Aufnhame gestartet</speak>"),
	AlexaText(TextId.ZapCardTitle,"Umschalten"),
	AlexaText(TextId.ZapCardContent,"Umschalten"),
	AlexaText(TextId.ZapFailedSSML,"nichts"),
	AlexaText(TextId.ZapSSML,"<speak>Ich habe umgeschaltet zu: <p>%s</p></speak>"),
	AlexaText(TextId.SleepTimerCardTitle,"Sleep Timer"),
	AlexaText(TextId.SleepTimerCardContent,"Sleep Timer"),
	AlexaText(TextId.SleepTimerOffSSML,"<speak>Sleep Timer wurde deaktiviert</speak>"),
	AlexaText(TextId.SleepTimerResetSSML,"<speak>Es existiert bereits ein Sleep Timer mit <p>%s verbleibenden Minuten."~
							"Timer wurde auf %s Minuten zurückgesetzt.</p></speak>"),
	AlexaText(TextId.SleepTimerSetSSML,"<speak>Ich habe den Sleep Timer auf <p>%s Minuten eingestellt</p></speak>"),
	AlexaText(TextId.SleepTimerFailedSSML,"<speak>Der Timer konnte nicht gesetzt werden.</speak>"),
	AlexaText(TextId.SleepTimerNoTimerSSML,"<speak>Es gibt keinen Timer der deaktiviert werden könnte</speak>"),
	AlexaText(TextId.CurrentCardTitle,"Es läuft"),
	AlexaText(TextId.CurrentCardContent,"Es läuft"),
	AlexaText(TextId.CurrentSSML,"<speak>Du guckst gerade: <p>%s" ~
			"</p>Aktuell läuft:<p>%s</p></speak>"),
	AlexaText(TextId.CurrentNextSSML,"%s anschliessend läuft: <p>%s</p></speak>")
	
];
