module ask;

import vibe.d;

///
struct AlexaUser {
  string userId;
  string accessToken;
}

///
struct AlexaApplication {
  string applicationId;
}

///
struct AlexaRequstSession {
  @name("new")
  bool _new;
  string sessionId;
  AlexaApplication application;
  string[string] attributes;
  AlexaUser user;
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
  @optional
  string title;
  @optional
  string text;
  @optional
  string content;

  ///
  struct Image
  {
    string smallImageUrl;
    string largeImageUrl;
  }

  @optional
  Image image;
}

///
struct AlexaResponseReprompt {
  AlexaOutputSpeech outputSpeech;
}

///
struct AlexaResponse {
  AlexaOutputSpeech outputSpeech;
  @optional
  AlexaCard card;
  //@optional
  //AlexaResponseReprompt reprompt;
}

///
struct AlexaResult {

  @name("version") 
  string _version = "1.0";

  string[string] sessionAttributes;
  
  bool shouldEndSession;

  AlexaResponse response;
}

///
struct AlexaAudioPlayer
{
  string token;
  int offsetInMilliseconds;
  string playerActivity;
}

///
/+struct AlexaDevice
{
  supportedInterfaces
}+/

//see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#system-object
///
struct AlexaSystem
{
  AlexaApplication application;
  AlexaUser user;
  //AlexaDevice device;
}

//see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#context-object
///
struct AlexaRequestContext {
 AlexaSystem System;
 AlexaAudioPlayer AudioPlayer;
}

///
struct AlexaSlot
{
  string name;
  string value;
}

///
struct AlexaIntent
{
  string name;

  @optional
  AlexaSlot[string] slots;
}

///
struct AlexaRequestError
{
  string type;
  string message;
}

///
struct AlexaRequest
{
  string type;
  string requestId;
  string timestamp;
  string locale;

  @optional
  string reason;

  @optional
  AlexaRequestError error;

  @optional
  AlexaIntent intent;
}

//see https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-reference#request-format
///
struct AlexaRequestBody {

  @name("version") 
  string _version;

  AlexaRequstSession session;

  AlexaRequest request;
}
