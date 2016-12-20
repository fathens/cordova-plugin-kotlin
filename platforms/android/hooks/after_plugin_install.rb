#!/usr/bin/env ruby

require 'pathname'
require 'fetch_local_lib'
require_relative '../../../lib/cordova_plugin_kotlin'

def rewrite_gradle(file_src)
    file_dst = "#{file_src}.tmp"

    compile = true
    srcdirs = true
    plugin = true
    classpath = true

    open(file_src, 'r') { |src|
        open(file_dst, 'w') { |dst|
            src.each_line { |line|
                dst.puts line
                add_line = lambda { |text|
                    dst.puts "#{line.match(/^[\s]*/)[0]}#{text}"
                }
                if compile && line =~ /^\s*compile\s/
                    add_line.call "compile 'org.jetbrains.kotlin:kotlin-stdlib:1.+'"
                    compile = false
                end
                if srcdirs && line =~ /java\.srcDirs/
                    add_line.call "kotlin.srcDirs = ['kotlin']"
                    srcdirs = false
                end
                if plugin && line =~ /apply plugin:/
                    add_line.call "apply plugin: 'kotlin-android'"
                    plugin = false
                end
                if classpath && line =~ /classpath 'com\.android\.tools\.build:gradle:[1-2]\.[1-9]\./
                    add_line.call "classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.+'"
                    classpath = false
                end
            }
        }
    }
    File.rename(file_dst, file_src)
end

$PROJECT_DIR = Pathname.pwd.realpath
$PLATFORM_DIR = $PROJECT_DIR/'platforms'/'android'

rewrite_gradle $PLATFORM_DIR/'build.gradle'
