#!/bin/bash -eu
export PLATFORM_DIR_NAME="ios"
export UWEBRTC_DIR="$(pwd)/com.unity.webrtc"
export PATH="${UWEBRTC_DIR}/depot_tools:$PATH"
export PYTHON3_BIN="${UWEBRTC_DIR}/depot_tools/python-bin/python3"
export ARTIFACTS_DIR="${UWEBRTC_DIR}/artifacts/${PLATFORM_DIR_NAME}"
export WEBRTC_DIR="$(pwd)/src"
mkdir -p "$ARTIFACTS_DIR/lib"

for is_debug in "true" "false"
do
  for target_cpu in "x64" "arm64"
  do
    #keeping the build folders in a paltform, arch and debug specific folder
    #for quick rebuilds if code changes
    export OUTPUT_DIR="${UWEBRTC_DIR}/out/${PLATFORM_DIR_NAME}-${target_cpu}-${is_debug}"
    echo "Output to ${OUTPUT_DIR}"
    # generate ninja files
    gn gen "$OUTPUT_DIR" --root="${WEBRTC_DIR}" \
      --args="is_debug=${is_debug} \
      target_os=\"ios\" \
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
  done

  filename="libwebrtc.a"
  if [ $is_debug = "true" ]; then
    filename="libwebrtcd.a"
  fi

  # make universal binary
  lipo -create -output                   \
  "$ARTIFACTS_DIR/lib/${filename}"       \
  "$ARTIFACTS_DIR/lib/arm64/libwebrtc.a" \
  "$ARTIFACTS_DIR/lib/x64/libwebrtc.a"
  
  rm -r "$ARTIFACTS_DIR/lib/arm64"
  rm -r "$ARTIFACTS_DIR/lib/x64"
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