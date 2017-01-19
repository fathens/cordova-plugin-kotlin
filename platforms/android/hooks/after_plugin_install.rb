#!/usr/bin/env ruby

require 'pathname'

def rewrite_gradle(file)
    compile = true
    srcdirs = true
    plugin = true
    classpath = true

    lines = []
    open(file, 'r') { |src|
        src.each_line { |line|
            lines.push line
            add_line = lambda do |text|
                lines.push "#{line.match(/^[\s]*/)[0]}#{text}"
            end
            if compile && line =~ /^\s*compile\s/
                add_line["compile 'org.jetbrains.kotlin:kotlin-stdlib:1.+'"]
                compile = false
            end
            if srcdirs && line =~ /java\.srcDirs/
                add_line["kotlin.srcDirs = ['kotlin']"]
                srcdirs = false
            end
            if plugin && line =~ /apply plugin:/
                add_line["apply plugin: 'kotlin-android'"]
                plugin = false
            end
            if classpath && line =~ /classpath 'com\.android\.tools\.build:gradle:[1-2]\.[1-9]\./
                add_line["classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.+'"]
                classpath = false
            end
        }
    }
    open(file, 'w') { |dst|
        dst.puts lines
    }
end

$PROJECT_DIR = Pathname.pwd.realpath
$PLATFORM_DIR = $PROJECT_DIR/'platforms'/'android'

rewrite_gradle $PLATFORM_DIR/'build.gradle'
