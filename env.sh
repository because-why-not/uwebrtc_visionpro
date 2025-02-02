#!/bin/bash -eu
#change this if you need a custom python version
#last tested Python 3.9.16
#NOTE: 3.10 and above might break the old python
#scripts in the webrtc repository!
export PYTHON3_BIN="python3"
#using python3 via depot_tools (seems to cause bugs sometimes?)
#export PYTHON3_BIN="$(pwd)/depot_tools/python-bin/python3"
echo "Using python command: ${PYTHON3_BIN}"
echo "versions:"
${PYTHON3_BIN} --version
#last tested  3.28.1
cmake --version

#depot tools are needed for building webrtc
#we check them out as subrepository to automate this
if [ -z "${DEPOT_TOOLS-}" ]; then
    export DEPOT_TOOLS=`realpath ./depot_tools`
fi
echo "Using depot tools form ${DEPOT_TOOLS}"
#This should stop the depot_tools from automatically updating
#to reduce the risk of going out of sync with the old WebRTC build scripts
export DEPOT_TOOLS_UPDATE=0
#if no excode path is set we do this here. 
if [ -z "${XCODE_PATH-}" ]; then
    export XCODE_PATH="/Applications/Xcode.app"
fi
echo "Using xcode form ${XCODE_PATH}"

#add depot tools to path to access gn and ninja
if [[ ":$PATH:" != *":${DEPOT_TOOLS}:"* ]]; then
    export PATH=${DEPOT_TOOLS}:$PATH
    echo "Included depot tools into PATH"
fi
