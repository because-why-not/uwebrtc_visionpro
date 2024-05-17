#!/bin/bash -eu
source env.sh
cd ./com.unity.webrtc 

export SOLUTION_DIR=$(pwd)/Plugin~
export DYLIB_FILE=$(pwd)/Runtime/Plugins/macOS/libwebrtc.dylib
export ARTIFACTS_DIR="$(pwd)/artifacts/mac"

# copy from WebRTC build (must be done first via ./build_webrtc scripts)
rsync -rav --delete ${ARTIFACTS_DIR}/ $SOLUTION_DIR/webrtc

# Remove old dylib file
rm -rf "$DYLIB_FILE"

# Build UnityRenderStreaming Plugin
cd "$SOLUTION_DIR"
cmake --preset=macos -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
cmake --build --preset=release-macos --target=WebRTCPlugin
