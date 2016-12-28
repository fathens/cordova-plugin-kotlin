require 'pathname'

module Kotlin
    def self.write_android_mafifest(target_file, package_name)
        File.open(target_file, 'w') { |dst|
            dst.puts <<~EOF
            <?xml version="1.0" encoding="utf-8"?>
            <manifest xmlns:android="http://schemas.android.com/apk/res/android"
                package="#{package_name}" >
                <uses-sdk android:minSdkVersion="19" />
                <application>
                    <activity android:name=".MainActivity" >
                        <intent-filter>
                            <action android:name="android.intent.action.MAIN" />
                            <category android:name="android.intent.category.LAUNCHER" />
                        </intent-filter>
                    </activity>
                </application>
            </manifest>
            EOF
        }
    end
end
