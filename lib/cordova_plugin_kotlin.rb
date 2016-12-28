require 'rexml/document'
require_relative 'cordova_plugin_kotlin/android_manifest'
require_relative 'cordova_plugin_kotlin/gradle_file'

def log(msg)
    puts msg
end

def log_header(msg)
    log "################################"
    log "#### #{msg}"
end

module Kotlin
    def self.mk_skeleton(platform_dir)
        xml = File.open(platform_dir.dirname.dirname/'plugin.xml') {|src| REXML::Document.new src }
        plugin_id = xml.elements['plugin'].attributes['id']
        write_build_gradle(platform_dir/'build.gradle')
        write_android_mafifest(platform_dir/'src'/'main'/'AndroidManifest.xml', plugin_id)
    end
end
