require 'pathname'

class PluginGradle
    def self.with_lineadapter(base_dir, repo_dir)
        gradle = PluginGradle.new(base_dir)
        gradle.jar_files.concat Pathname.glob(repo_dir/'*.jar')
        gradle.jni_dirs.push repo_dir/'libs'
        gradle
    end

    attr_accessor :base_dir, :jar_files, :jni_dirs

    def initialize(base_dir)
        @base_dir = base_dir
        @jar_files = []
        @jni_dirs = []
    end

    def write
        target_file = 'plugin.gradle'

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
            "            srcDirs += '#{mk_path(x)}'"
            }
            dst.puts <<~EOF
                    }
                }
            }
            EOF
        }
    end

    def mk_path(p)
        p.relative_path_from @base_dir
    end
end
