#!/usr/bin/env node
var child_process = require('child_process');

module.exports = function(context) {
	var fs = context.requireCordovaModule('fs');
	var path = context.requireCordovaModule('path');
	var deferral = context.requireCordovaModule('q').defer();

	var make_platform_dir = function(base) {
		return path.join(base, 'platforms', 'android');
	}
	var platformDir = make_platform_dir(context.opts.projectRoot)
	var pluginDir = path.join(context.opts.projectRoot, 'plugins', context.opts.plugin.id);

	var main = function() {
		process.stdout.write("################################ Start preparing\n")

		var script = path.join(make_platform_dir(pluginDir), 'hooks', 'after_plugin_install.sh');
		process.stdout.write("Running " + script + "\n");
		var child = child_process.execFile(script, [ context.opts.plugin.id ], {
			cwd : platformDir
		}, function(error) {
			if (error) {
				deferral.reject(error);
			} else {
				process.stdout.write("################################ Finish preparing\n\n")
				deferral.resolve();
			}
		});
		child.stdout.on('data', function(data) {
			process.stdout.write(data);
		});
		child.stderr.on('data', function(data) {
			process.stderr.write(data);
		});
	}
	main();
	return deferral.promise;
};
