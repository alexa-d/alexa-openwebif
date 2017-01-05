'use strict';

var child_process = require('child_process');

// Set the PATH and LD_LIBRARY_PATH environment variables.
process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT'] + '/';
process.env['LD_LIBRARY_PATH'] = process.env['LAMBDA_TASK_ROOT'] + '/';

exports.handler = function(event, context) {
	console.log("node args event: "+JSON.stringify(event));
	console.log("node args context: "+JSON.stringify(context));
	var eventB64 = new Buffer(JSON.stringify(event)).toString('base64');
	var contextB64 = new Buffer(JSON.stringify(context)).toString('base64');
	
	var options = {};

	var callback = function(code,stdout,stderr) {
		console.log("code: "+code);
		console.log("err: "+stderr);
	    console.log("out: "+stdout);
	    context.succeed(JSON.parse(stdout));
  	};

	var proc = child_process.exec('./alexa-openwebif false ' + eventB64 + " " + contextB64, options, callback);
}