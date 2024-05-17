#!/bin/bash -eu
source env.sh
cd ./com.unity.webrtc


#
export PLATFORM_DIR_NAME="simxros"

#source code dir for the plugin
export SOLUTION_DIR=$(pwd)/Plugin~
#bin dir where cmake builds the files
export BINARY_DIR="${SOLUTION_DIR}/out/build/${PLATFORM_DIR_NAME}"
#library files form the webrtc build. must be done previously via ./build_webrtc_* scripts
export ARTIFACTS_DIR="$(pwd)/artifacts/${PLATFORM_DIR_NAME}"
#archive used to store the files before copying them to its final directory
export WEBRTC_ARCHIVE_DIR=${BINARY_DIR}/webrtc.xcarchive
#final output folder to store the plugin
export WEBRTC_FRAMEWORK_DIR=$(pwd)/Runtime/Plugins/${PLATFORM_DIR_NAME}


export CONFIGURATION=Release

#cmake currently uses a fixed dir where it expects the input webrtc builds to be
rsync -rav --delete ${ARTIFACTS_DIR}/ $SOLUTION_DIR/webrtc

# Build webrtc Unity plugin 
cd "$SOLUTION_DIR"
rm -rf ${BINARY_DIR}
cmake . \
  -G Xcode \
  -D "XROS_OUT_DIR=../Runtime/Plugins/${PLATFORM_DIR_NAME}" \
  -D CMAKE_SYSTEM_NAME=visionOS \
  -D "CMAKE_OSX_ARCHITECTURES=arm64" \
  -D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
  -D "CMAKE_OSX_DEPLOYMENT_TARGET=1.0" \
  -B ${BINARY_DIR}

xcodebuild \
  -sdk xrsimulator \
  -arch 'arm64' \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -target WebRTCLib \
  -configuration ${CONFIGURATION}

xcodebuild archive \
  -sdk xrsimulator \
  -arch 'arm64' \
  -scheme WebRTCPlugin \
  -project ${BINARY_DIR}/webrtc.xcodeproj \
  -configuration ${CONFIGURATION} \
  -archivePath "$WEBRTC_ARCHIVE_DIR"


rm -rf "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"
cp -r "$WEBRTC_ARCHIVE_DIR/Products/@rpath/webrtc.framework" "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"
