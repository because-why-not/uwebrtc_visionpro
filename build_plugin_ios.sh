#!/bin/bash -eu
source env.sh
cd ./com.unity.webrtc 

export ARTIFACTS_DIR="$(pwd)/artifacts/ios"
export SOLUTION_DIR=$(pwd)/Plugin~
export WEBRTC_FRAMEWORK_DIR=$(pwd)/Runtime/Plugins/iOS
export BINARY_DIR="${SOLUTION_DIR}/out/build/ios"
export WEBRTC_ARCHIVE_DIR=${BINARY_DIR}/webrtc.xcarchive
export WEBRTC_SIM_ARCHIVE_DIR=${BINARY_DIR}/webrtc-sim.xcarchive


rsync -rav --delete ${ARTIFACTS_DIR}/ $SOLUTION_DIR/webrtc



# Build webrtc Unity plugin 
cd "$SOLUTION_DIR"
rm -rf ${BINARY_DIR}
cmake . \
  -G Xcode \
  -D CMAKE_SYSTEM_NAME=iOS \
  -D "CMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
  -D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
  -D "CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0" \
  -D "CMAKE_OSX_DEPLOYMENT_TARGET=12.0" \
  -B ${BINARY_DIR}

xcodebuild \
  -sdk iphonesimulator \
  -arch 'x86_64' \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -target WebRTCLib \
  -configuration Release

xcodebuild archive \
  -sdk iphonesimulator \
  -arch 'x86_64' \
  -scheme WebRTCPlugin \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -configuration Release \
  -archivePath "$WEBRTC_SIM_ARCHIVE_DIR"

xcodebuild \
  -sdk iphoneos \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -target WebRTCLib \
  -configuration Release

xcodebuild archive \
  -sdk iphoneos \
  -scheme WebRTCPlugin \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -configuration Release \
  -archivePath "$WEBRTC_ARCHIVE_DIR"

rm -rf "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"
cp -r "$WEBRTC_ARCHIVE_DIR/Products/@rpath/webrtc.framework" "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"
