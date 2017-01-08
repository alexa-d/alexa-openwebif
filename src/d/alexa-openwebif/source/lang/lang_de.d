module lang.lang_de;

import lang.types;

///
enum AlexaText[] AlexaText_de = [
	AlexaText(TextId.PleaseLogin,"Bitte log dich ein"),
	AlexaText(TextId.PleaseLoginSSML,"<speak>Bitte log dich in deiner Alexa App ein</speak>"),
	AlexaText(TextId.DefaultCardTitle,"Telly"),
	AlexaText(TextId.HelloCardContent,"Telly sagt hallo zu %s"),
	AlexaText(TextId.HelloSSML,"<speak>Hallo %s, danke fürs einloggen. Was kann ich für dich tun?</speak>"),
];
