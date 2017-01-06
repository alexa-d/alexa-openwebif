# alexa-openwebif
alexa skill to control your openwebif device.

development blog post: [Alexa in D](http://blog.extrawurst.org/programming/dlang/alexa/2017/01/06/alexa-in-d.html)

dependencies:

* [alexa-skill-kit-d](https://github.com/Extrawurst/alexa-skill-kit-d)
* [openwebif-client-d](https://github.com/Extrawurst/openwebif-client-d)
* [vibe.d](https://github.com/rejectedsoftware/vibe.d)

## usage

To host this skill in your own aws account:

```
# setup environments variables
OPENWEBIF_URL=http://my.web.domain
AWS_REGION=AWS region you are hosting the lambda function in
AWS_LAMBDA_NAME=AWS lambda function name
AWS_KEY_ID=IAM key id
AWS_KEY_SECRET=IAM key secret
```

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

## todo

current major planned features:

1. support english language ([#6](https://github.com/Extrawurst/alexa-openwebif/issues/6))
2. support user database to allow publication ([#14](https://github.com/Extrawurst/alexa-openwebif/issues/14))
3. support timeshift ([#5](https://github.com/Extrawurst/alexa-openwebif/issues/5))
