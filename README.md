# alexa-openwebif
alexa skill to control your openwebif device

## usage

To host this skill in your own aws account:

```
# setup environments variables
OPENWEBIF_URL=http://my.web.domain
AWS_REGION=AWS region you are hosting the lambda function in
AWS_LAMBDA_NAME=AWS lambda function name
```

```
$ vagrant up
$ vagrant ssh
$ aws initialize
$ cd /vagrant/src
$ ./run.sh
```