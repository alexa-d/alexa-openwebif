printf "\nbuild d app\n"
cd d/alexa-openwebif
dub build

printf "\nbuild zip\n"
zip -j arch.zip ../../node/index.js libssl.so.10 libevent-2.0.so.5 libcrypto.so.10 libevent_pthreads-2.0.so.5 alexa-openwebif

printf "\nupload zip\n"
aws lambda update-function-code --function-name <name> --zip-file fileb://./arch.zip

printf "\nset environment\n"
aws lambda update-function-configuration --function-name <name> --environment 'Variables={OPENWEBIF_URL="http://your.openwebif.endpoint"}'

printf "\ntest invoke\n"
cd ../../
aws lambda invoke --invocation-type RequestResponse --function-name <name> --region <region> --log-type Tail --payload '{"dummy":"dummyvalue"}' outputfile.txt