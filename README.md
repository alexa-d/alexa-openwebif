[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/Wallentowitz) [![Build Status](https://travis-ci.org/alexa-d/alexa-openwebif.svg)](https://travis-ci.org/alexa-d/alexa-openwebif) ![Submission State](https://img.shields.io/badge/submission_state-in_progress-yellow.svg)
# Enigma2 Control Alexa Skill
### Dreambox User mit Dreambox Webcontrol können den Skill bisher leider nicht benutzen. Wir empfehlen die Installation des Openwebif Plugins (see Ticket [#132](https://github.com/alexa-d/alexa-openwebif/issues/132) and [#126](https://github.com/alexa-d/alexa-openwebif/issues/126) for ipk)
### For Beta Testers (german only right now)
Send mail with your amazon account email to fabian at wallentowitz dot de 
After getting feedback
Use this [Link](https://skills-store.amazon.com/deeplink/tvt/27c5832d8e3d52b83f7062d3689189c004e06b54743d201e47223db66a0b8a7a6b5d56aeabe89aa098a8fc032cd1c6c4850ba0342137be20f3e48ffc1d44660d2b90291b57348c50208507d77bfbee9d2123f30f388d2091c5de00b5a324e51d1b676e631c956d2efca510272bc5b4579a7abaca7c932ab6d85d9a76c3e81d887cbcb7f3a8bae847e7cde0b0ada8dac36c2fc71aa5a67b97c8f25af05f90545b06d26b59bd83f42af4d239) to subscribe for beta testing.
#### scroll down for self deployment instruction or click [HERE](https://github.com/alexa-d/alexa-openwebif#self-deployment)
Mit dem Enigma2 Control Alexa Skill kannst du deinen Enigma2 Linux Receiver via Amazon Echo steuern. Der Skill befindet sich im Review durch Amazon und ist bald verfügbar. 
Damit der Skill bei dir funktioniert müssen folgende Gegebenheiten erfüllt sein:
* Der Skill muss aktiviert sein
* Das Account-Linking muss erfolgt sein
* Dein Receiver muss aus dem Internet erreichbar sein ([Hier](http://techify.de/vu-tutorial-aufnahmen-timer-mit-android-unterwegs-programmieren/) ist ein Tutorial um deine Box aus dem Internet erreichbar zu machen)
* Du musst deine Zugangsdaten für die Box in unserem [Portal](https://funok.de:8080) hinterlegen (URL muss mit http:// oder https:// beginnen)

Wenn alle Gegebenheiten erfüllt sind kannst du mit `Alexa, hilfe mit Enigma` eine Liste über die verfügbaren Kommandos erhalten. Hier folgt die komplette Übersicht aller möglichen Befehle:

### Was läuft gerade?
`Alexa, frag Enigma Control`
  * `was gerade läuft`
  * `was ich gerade gucke`
  * `was aktuell läuft`
  
`Alexa,`

  * `was ist das`
  * `aktuell`
  * `was läuft gerade`
  * `was gucke ich gerade`

`mit Enigma Control`

### Kanalübersicht
`Alexa, frag Enigma Control`
  * `nach meinen kanälen`
  * `nach meinen sendern`
  * `nach meinen services`

`Alexa,`

  * `meine Kanäle`
  * `meine Sender`
  * `meine Services`

`mit Enigma Control`

### Aufnahmen
`Alexa, frag Enigma Control`
  * `nach meinen aufnahmen`
  * `nach meinen filmen`
  * `welche aufnahmen habe ich`

`Alexa,`

  * `meine aufnahmen`

`mit Enigma Control`

### Lautstärkenregelung
`Alexa, frag Enigma Control`
  * `nach Ton ausschalten`
  * `nach stumm schalten`
  * `Ton auszumachen`
  * `die Lautstärke auf <0-100> zu setzen`
  
`Alexa,`

  * `Ton ausschalten`
  * `mute`
  * `Stumm schalten`
  * `Ton an`
  * `Ton aus`
  * `erhöhe die Lautstärke`
  * `verringer die Lautstärke`
  * `Lautstärke hoch`
  * `Lautstärke runter`
  * `lauter`
  * `leiser`
  * `die Lautstärke auf <0-100> setzen`
  * `Lautstärke auf <0-100>`
  * `Lautstärke auf <0-100> erhöhen`
  * `Lautstärke auf <0-100> verringern`

`mit Enigma Control`

### Umschalten auf Kanal
`Alexa, frag Enigma Control`
  * `und schalte auf <Kanal>`
  * `auf <Kanal> zu schalten`
  * `auf <Kanal> zu wechseln`
  * `den Sender <Kanal> einzuschalten`
  * `zu <Kanal> zu schalten`
  * `zu <Kanal> zu wechseln`
  
`Alexa,`

  * `wechsel zu <Kanal>`
  * `zap zu <Kanal>`
  * `schalte auf <Kanal>`
  * `schalte <Kanal>`
  * `wechsel <Kanal>`
  * `umschalten auf <Kanal>`
  * `umschalten zu <Kanal>`

`mit Enigma Control`

### Umschalten auf Sendung (wenn sie läuft - wenn nicht, sagt Alexa dir wann die Sendung wieder läuft)
`Alexa, frag Enigma Control`
  * `ob die Sendung <Sendung> läuft`
  * `ob Sendung <Sendung> läuft`
  * `ob <Sendung> läuft`
  * `nach der Sendung <Sendung>`
  * `nach Sendung <Sendung>`
  
`Alexa,`
  * `such nach Sendung <Sendung>`
  * `Sendung <Sendung>`
  * `schalte auf <Sendung>`
  * `schalte <Sendung>`
  * `wechsel <Sendung>`
  * `umschalten auf <Sendung>`
  * `umschalten zu <Sendung>`

`mit Enigma Control`

### Hoch-/Runterschalten
`Alexa,`
  * `schalte runter`
  * `schalte hoch`
  * `runter schalten`
  * `hoch schalten`
  
`mit Enigma Control`

### Zufälliges umschalten
`Alexa,`
  * `schalte zufällig um`
  * `zufällig umschalten`
  
`mit Enigma Control`

### Standby 
`Alexa,`
  * `Standby umschalten`
  * `Standby einschalten`
  * `Standby ausschalten`
  * `ausschalten`
  * `einschalten`
  * `anschalten`
  
`mit Enigma Control`

### (Sofort-)Aufnahme starten
`Alexa,`
  * `aufnehmen`
  * `Aufnahme starten`
  * `jetzt aufnehmen`
  
`mit Enigma Control`

### Pause/Fortsetzen/Stop
`Alexa,`
  * `pausieren`
  * `pause`
  * `fortsetzen`
  * `stop`
  
`mit Enigma Control`

### Sleeptimer (erwartet Minuten - 0 Minuten deaktiviert den Timer)
`Alexa, frag Enigma Control`
  * `nach sleep timer in <minuten> Minuten`
  * `nach einschlafen in <minuten> Minuten`
  * `nach ausschalten in <minuten> Minuten`

`Alexa,`
  * `sleep timer in <minuten> Minuten`
  * `sleep timer <minuten> Minuten`

`mit Enigma Control`

### Vorheriger Kanal 
`Alexa,`
  * `vorheriger Kanal`
  * `vorheriger Sender`
  * `letzter Kanal`
  * `letzter Sender`
  * `zurückschalten`
  * `zurück schalten`
  * `zurück`
  
`mit Enigma Control`

### About / Über uns
`Alexa, frag Enigma`
  * `worin es geschrieben wurde`
  * `wo es her kommt`
  * `wer es geschrieben hat`

`Alexa,`
  * `wer ist dein vater`

`mit Enigma Control`


# Self-Deployment
alexa skill to control your enigma2 device.

development blog post: [Alexa in D](http://blog.extrawurst.org/programming/dlang/alexa/2017/01/06/alexa-in-d.html)

dub dependencies:

* [alexa-skill-kit-d](https://github.com/Extrawurst/alexa-skill-kit-d)
* [openwebif-client-d](https://github.com/Extrawurst/openwebif-client-d)
* [vibe.d](https://github.com/rejectedsoftware/vibe.d)
* [vibe-aws](https://github.com/vibe-aws/vibe-aws)

## usage

To host this skill in your own aws account:

**note**: needs vagrant >= 1.8.0 

```
# setup environments variables
AWS_REGION=AWS region you are hosting the lambda function in
AWS_LAMBDA_NAME=AWS lambda function name
AWS_KEY_ID=IAM key id
AWS_KEY_SECRET=IAM key secret
AWS_DYNAMODB_REGION=AWS region where dynamodb tables are running
OPENWEBIF_TABLENAME=DynamoDB tablename for openwebif database
```

You need to setup one DynamoDB Table
ENV OPENWEBIF_TABLENAME (as defined before in env vars) with primary partition key "accessToken" of type string

As you can see before we can upload our code to aws lambda we have to create the lambda function (and give it a name that we can put in the env vars). To do this please follow this documentation: https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/developing-an-alexa-skill-as-a-lambda-function

If you never created a skill for alexa before get youserlf familiar with the alexa dev console here: https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/registering-and-managing-alexa-skills-in-the-developer-portal

Now building the skill binary and uploading it to lambda is automated. since we need linux binaries I used vagrant to boot up a machine and the building happens in there:

```
# bring up vagrant and ssh into it
$ vagrant up
$ vagrant ssh

# build and upload to aws lambda
$ cd /vagrant/src
$ ./run.sh
```

After that you need to build the alexa-portal to host the user interface for account linking based on Login-with-Amazon (ssl certificate need - server.key and server.crt).
Provide your url with https protocol, port (default 8080) and path /login in your alexa skill as authorization URL in account linking options. Please choose Implicit grant. 

## main featueres

* timeshift
* epg search
* zapping (to channel or show)
* program info
* turn on/off
* volume control
* recording
