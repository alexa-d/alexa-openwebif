module ask;

import vibe.d;

///
struct AlexaSession {
}

///
struct AlexaOutputSpeech {
  ///	
  enum Type
  {
    PlainText,
    SSML,
  }

  @byName
  Type type = Type.PlainText;
  string text;
  string ssml;
}

// see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#card-object
///
struct AlexaCard {

  ///
  enum Type
  {
    Simple,
    Standard,
    LinkAccount
  }

  @byName
  Type type = Type.Simple;
  string title;
  string text;
  string content;
}

///
struct AlexaResponseReprompt {
  AlexaOutputSpeech outputSpeech;
}

///
struct AlexaResponse {
  AlexaOutputSpeech outputSpeech;
  AlexaCard card;
  AlexaResponseReprompt reprompt;
}

///
struct AlexaResult {

  @name("version") 
  string _version = "1.0";

  AlexaSession sessionAttributes;
  
  bool shouldEndSession;

  AlexaResponse response;
}
