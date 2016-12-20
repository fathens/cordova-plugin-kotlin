require "spec_helper"

describe 'Gradle file' do
    context "with something" do
        a = PluginGradle.new
        it { expect(a.jar_files.empty?).to eq(true) }
        it { expect(a.jni_dirs.empty?).to eq(true) }
    end
end
