printf "\nbuild d app\n"
cd d/alexa-openwebif
dub build --compiler=ldc2

printf "\nbuild zip\n"
zip -j arch.zip ../../node/index.js libssl.so.10 libevent-2.0.so.5 libcrypto.so.10 libevent_pthreads-2.0.so.5 alexa-openwebif

printf "\nupload zip\n"
aws lambda update-function-code --function-name $AWS_LAMBDA_NAME --zip-file fileb://./arch.zip

printf "\nset environment\n"
aws lambda update-function-configuration --function-name $AWS_LAMBDA_NAME --environment "Variables={OPENWEBIF_URL=$OPENWEBIF_URL}"

printf "\ntest invoke\n"
cd ../../
aws lambda invoke --invocation-type RequestResponse --function-name $AWS_LAMBDA_NAME --log-type Tail --payload '{"session": {"sessionId": "","application": {"applicationId": ""},"attributes": {},"user": {"userId": ""},"new": true},"request": {"type": "IntentRequest","requestId": "","locale": "","timestamp": "", "intent":{"name":"IntentCurrent"}},"version": ""}' outputfile.txt
