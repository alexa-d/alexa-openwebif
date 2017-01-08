module lang.lang_en;

import lang.types;

///
enum AlexaText[] AlexaText_en = [
	AlexaText(TextId.PleaseLogin,"Please login"),
	AlexaText(TextId.PleaseLoginSSML,"<speak>Please use your Alexa app to log in</speak>"),
	AlexaText(TextId.DefaultCardTitle,"Telly"),
	AlexaText(TextId.HelloCardContent,"Telly says hello to %s"),
	AlexaText(TextId.HelloSSML,"<speak>Hello %s, thanks for logging in. What can I do for you?</speak>"),
];
