#!/usr/bin/env node

var log = function() {
	var args = Array.prototype.map.call(arguments, function(value) {
		if (typeof value === 'string') {
			return value;
		} else {
			return JSON.stringify(value, null, '\t')
		}
	});
	process.stdout.write(args.join('') + '\n');
}

module.exports = function(context) {
	var fs = context.requireCordovaModule('fs');
	var path = context.requireCordovaModule('path');
	var deferral = context.requireCordovaModule('q').defer();
	var async = context.requireCordovaModule(path.join('request', 'node_modules', 'form-data', 'node_modules', 'async'));

	var platformDir = path.join(context.opts.projectRoot, 'platforms', 'android');

	var adjustIndent = function(base, content) {
		var first = base.match(/^[ \t]*/);
		var indent = (first && first.length > 0) ? first[0] : '';
		return indent + content;
	}
	
	var build_gradle = function(next) {
		var target = path.join(platformDir, 'build.gradle');
		log("Editing ", target);
		async.waterfall(
				[
				function(next) {
					fs.readFile(target, 'utf-8', next);
				},
				function(content, next) {
					var cond = {
							compile: 0,
							classpath: 0,
							plugin: 0,
							srcdirs: 0
					}
					var lines = content.split('\n').map(function (line) {
						var result = [line];
						var adding;
						if (cond.compile === 1) {
							adding = "compile 'org.jetbrains.kotlin:kotlin-stdlib:0.14.449'";
							cond.compile = 0;
						}
						if (cond.classpath === 0) {
							var found = line.match(/classpath 'com\.android\.tools\.build:gradle:1\.0\.0\+'/);
							if (found && found.length > 0) {
								result[0] = line.replace(/1\.0\.0/, '1.1.0');
								adding = "classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:0.14.449'";
								cond.classpath = 1;
							}
						}
						if (cond.plugin === 0 && line.indexOf('apply plugin:') > -1) {
							adding = "apply plugin: 'kotlin-android'";
							cond.plugin = 1;
						}
						if (cond.srcdirs === 0 && line.indexOf('java.srcDirs') > -1) {
							adding = "kotlin.srcDirs = ['kotlin']";
							cond.srcdirs = 1;
						}
						if (line.indexOf('dependencies') === 0) {
							cond.compile = 1;
						}
						if (adding) result.push(adjustIndent(line, adding));
						return result;
					}).reduce(function(a, b) {
						return a.concat(b);
					}, []);
					next(null, lines);
				},
				function(lines, next) {
					fs.writeFile(target, lines.join('\n'), 'utf-8', next);
				}
				 ], next);
	}
	
	var main = function() {
		async.parallel(
				[
				build_gradle
				],
				function(err, result) {
					if (err) {
						log(err);
						deferral.reject(err);
					} else {
						deferral.resolve(result);
					}
				});
	}
	main();
	return deferral.promise;
};
