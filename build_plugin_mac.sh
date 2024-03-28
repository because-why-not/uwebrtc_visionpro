#!/bin/bash -eu
pushd ./com.unity.webrtc 

export SOLUTION_DIR=$(pwd)/Plugin~
export DYLIB_FILE=$(pwd)/Runtime/Plugins/macOS/libwebrtc.dylib
export ARTIFACTS_DIR="$(pwd)/artifacts/mac"

# Download LibWebRTC 
rsync -rav --delete ${ARTIFACTS_DIR}/ $SOLUTION_DIR/webrtc

# Remove old dylib file
rm -rf "$DYLIB_FILE"

# Build UnityRenderStreaming Plugin
cd "$SOLUTION_DIR"
cmake --preset=macos
cmake --build --preset=release-macos --target=WebRTCPlugin
popd