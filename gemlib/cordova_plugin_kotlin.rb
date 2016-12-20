require 'pathname'

def log(msg)
    puts msg
end

def log_header(msg)
    log "################################"
    log "#### #{msg}"
end

def write_build_gradle(target_file, cordova_srcdir)
    File.open(target_file, 'w') { |dst|
        dst.puts <<~EOF
        buildscript {
            repositories {
                mavenCentral()
            }
            dependencies {
                classpath 'com.android.tools.build:gradle:2.+'
                classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.+"
            }
        }
        apply plugin: 'com.android.application'
        apply plugin: 'kotlin-android'

        repositories {
            mavenCentral()
        }

        apply from: "plugin.gradle"

        dependencies {
            compile "org.jetbrains.kotlin:kotlin-stdlib:1.+"
        }

        android {
            compileSdkVersion 'android-21'
            buildToolsVersion '25.0.2'
            sourceSets {
                main.java {
                    srcDirs += '#{cordova_srcdir.relative_path_from PLATFORM_DIR}'
                    srcDirs += 'src/main/kotlin'
                }
            }
        }
        EOF
    }
end

class PluginGradle
    attr_accessor :jar_files, :jni_dirs

    def initialize
        @jar_files = []
        @jni_dirs = []
    end

    def write(target_file, base_dir = nil)
        base_dir ||= target_file.dirname
        mk_path = lambda { |p|
            p.relative_path_from base_dir
        }

        files_line = @jar_files.map { |x|
            "'#{mk_path(x)}'"
        }.join(', ')

        File.open(target_file, 'w') { |dst|
            dst.puts <<~EOF
            dependencies {
                compile files(#{files_line})
            }
            android {
                sourceSets {
                    main.jniLibs {
            EOF
            dst.puts @jni_dirs.map { |x|
            "            srcDirs += '#{mk_path.call(x)}'"
            }
            dst.puts <<~EOF
                    }
                }
            }
            EOF
        }
    end
end
