#!/bin/bash
set -eu

echo "################################"
echo "#### Edit build.gradle"

file=build.gradle
echo "Edit $(pwd)/$file"
[ -f "$file" ] || exit 1

cat "$file" | awk '
    /classpath '\''com\.android\.tools\.build:gradle:1\.0\.0\+'\''/ {
        sub("1\.0\.0", "1.1.0")
        print $0
        sub("[^ ].*", "classpath '\''org.jetbrains.kotlin:kotlin-gradle-plugin:0.14.449'\''")
    }
    { print $0 }
    compile == 1 {
        sub("[^ ].*", "compile '\''org.jetbrains.kotlin:kotlin-stdlib:0.14.449'\''")
        print $0
        compile=0
    }
    /apply plugin:/ && plugin == 0 {
        sub("[^ ].*", "apply plugin: '\''kotlin-android'\''")
        print $0
        plugin = 1
    }
    /java\.srcDirs/ && srcdirs == 0 {
        sub("[^ ].*", "kotlin.srcDirs = ['\''kotlin'\'']")
        print $0
        srcdirs = 1
    }
    /^dependencies / {
        compile=1
    }
' > "${file}.tmp"

diff "$file" "${file}.tmp" || echo "[!] Kotlin src dir is set to '/kotlin'"
mv -f "${file}.tmp" "$file"
