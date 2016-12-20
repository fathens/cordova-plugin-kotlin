require 'pathname'

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
