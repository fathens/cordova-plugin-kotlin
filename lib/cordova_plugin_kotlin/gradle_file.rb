require 'pathname'

def write_build_gradle(target_file, cordova_srcdir, base_dir = nil)
    base_dir ||= target_file.dirname
    mk_path = lambda { |p|
        p.relative_path_from base_dir
    }
    log_header "Writing #{target_file}"
    log " on #{base_dir}"

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
                    srcDirs += '#{mk_path.call cordova_srcdir}'
                    srcDirs += 'src/main/kotlin'
                }
            }
        }
        EOF
    }
end
