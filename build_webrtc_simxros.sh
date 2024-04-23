#!/bin/bash -eu
set -e
source env.sh

export PLATFORM_DIR_NAME="simxros"
export UWEBRTC_DIR="$(pwd)/com.unity.webrtc"
export PATH="${UWEBRTC_DIR}/depot_tools:$PATH"
export ARTIFACTS_DIR="${UWEBRTC_DIR}/artifacts/${PLATFORM_DIR_NAME}"
export WEBRTC_DIR="$(pwd)/src"
mkdir -p "$ARTIFACTS_DIR/lib"

for is_debug in "true" "false"
do
    target_cpu="arm64"
    #keeping the build folders in a paltform, arch and debug specific folder
    #for quick rebuilds if code changes
    export OUTPUT_DIR="${UWEBRTC_DIR}/out/${PLATFORM_DIR_NAME}-${target_cpu}-${is_debug}"
    echo "Output to ${OUTPUT_DIR}"
    # generate ninja files
    gn gen "$OUTPUT_DIR" --root="src" \
      --args="is_debug=${is_debug} \
      target_os=\"ios\" \
      xros=true \
      ios_target_override=\"arm64-apple-xros1.0-simulator\" \
      ios_sdk_override=\"${XCODE_PATH}/Contents/Developer/Platforms/XRSimulator.platform/Developer/SDKs/XRSimulator.sdk\" \
      clang_base_path=\"${XCODE_PATH}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/\" \
      clang_use_chrome_plugins = false \
      use_lld=false \
      target_cpu=\"${target_cpu}\" \
      rtc_use_h264=false \
      use_custom_libcxx=false \
      treat_warnings_as_errors=false \
      ios_enable_code_signing=false \
      rtc_include_tests=false \
      rtc_build_examples=false \
      use_cxx17=true"

  # build static library
  ninja -C "$OUTPUT_DIR" webrtc

  # copy static library
  mkdir -p "$ARTIFACTS_DIR/lib/${target_cpu}"
  cp "$OUTPUT_DIR/obj/libwebrtc.a" "$ARTIFACTS_DIR/lib/${target_cpu}/"
  

  filename="libwebrtc.a"
  if [ $is_debug = "true" ]; then
    filename="libwebrtcd.a"
  fi

  # make universal binary
  cp "$ARTIFACTS_DIR/lib/arm64/libwebrtc.a" "$ARTIFACTS_DIR/lib/${filename}"
  rm -r "$ARTIFACTS_DIR/lib/arm64"
done


"$PYTHON3_BIN" "${WEBRTC_DIR}/tools_webrtc/libs/generate_licenses.py" \
  --target :webrtc "$OUTPUT_DIR" "$OUTPUT_DIR"

cd ${WEBRTC_DIR}
find . -name "*.h" -print | cpio -pd "$ARTIFACTS_DIR/include"

cp "$OUTPUT_DIR/LICENSE.md" "$ARTIFACTS_DIR"

# create zip
cd "$ARTIFACTS_DIR"
zip -r webrtc-${PLATFORM_DIR_NAME}.zip lib include LICENSE.md
mv webrtc-${PLATFORM_DIR_NAME}.zip ..