#!/bin/bash -eu
./build_webrtc_mac.sh && ./build_webrtc_ios.sh && ./build_webrtc_xros.sh && ./build_webrtc_simxros.sh
./build_plugin_ios.sh && ./build_plugin_simxros.sh && ./build_plugin_mac.sh && ./build_plugin_xros.sh
