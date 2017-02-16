[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/Wallentowitz) [![Build Status](https://travis-ci.org/alexa-d/alexa-openwebif.svg)](https://travis-ci.org/alexa-d/alexa-openwebif)
# alexa-openwebif
alexa skill to control your openwebif device.

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

## todo

current major planned features:

1. conversation mode
