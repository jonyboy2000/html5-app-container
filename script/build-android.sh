#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh

# Copy files into app.
rm -f tmp/android/assets/www/master.css
rm -f tmp/android/assets/www/main.js
rm -rf tmp/android/assets/www/css
rm -rf tmp/android/assets/www/img
rm -rf tmp/android/assets/www/js
cp -r app/* tmp/android/assets/www/

# Build the debug app.
cd tmp/android
./cordova/build --debug
mkdir -p bin
cd ../..
cp "tmp/android/bin/$APP_NAME-debug.apk" bin/

# Build the release app.
cd tmp/android
./cordova/build --release
cd ../..

# Sign the release app.
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore keys/android/release.keystore -storepass 'store-password' \
    -keypass 'key-password' \
    -signedjar "tmp/android/bin/$APP_NAME-release-unaligned.apk" \
    "tmp/android/bin/$APP_NAME-release-unsigned.apk" \
    android_release
zipalign 4 "tmp/android/bin/$APP_NAME-release-unaligned.apk" \
    "tmp/android/bin/$APP_NAME-release.apk"

# Copy the signed app to bin/.
cp "tmp/android/bin/$APP_NAME-release.apk" bin/
