#!/usr/bin/env node

var child_process = require('child_process');

module.exports = function(context) {
	var fs = context.requireCordovaModule('fs');
	var path = context.requireCordovaModule('path');
	var deferral = context.requireCordovaModule('q').defer();
	var androidPlatformDir = path.join(context.opts.projectRoot, 'platforms', 'android');
	var androidPlatformDir = path.join(androidPlatformDir, 'hooks', 'after');

	var main = function() {
		deferral.resolve();
	};
	main();
	return deferral.promise;
};
