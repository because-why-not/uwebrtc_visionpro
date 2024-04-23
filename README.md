Follow the instructions below to build the plugin from scratch. If you just want to
run and test it check out: https://github.com/because-why-not/uwebrtc_visionpro_testproj


Before building make sure you have:
* Xcode 15.2 with vision os SDK (build a test project first to make sure everything is installed)
* the latest cmake (`brew install cmake`)
* an ARM based mac build machine
* Unity 2022.3.21f1

Ideally, try to build the official com.unity.webrtc first to make sure nothing is missing. 

# Build
## Setup
In the terminal run the following:

    #this checks out the repository and its submoduels
    #this includes a fork of com.unity.webrtc which is absolutely massive. We use "--shallow-submodule" to reduce the size
    git clone --recurse-submodules --shallow-submodule https://github.com/because-why-not/uwebrtc_visionpro.git
    cd uwebrtc_visionpro
    #this will download third party dependencies of libwebrtc and can take a long time
    ./init.sh


If you use a custom Xcode location run
`export XCODE_PATH=/YOUR/PATH/Xcode.app`
or edit the env.sh. 

## Building

    #build libwebrtc for the visionos simulator
    ./build_webrtc_simxros.sh
    
    #build the plugins
    ./build_plugin_simxros.sh
    
    #for the device build
    ./build_webrtc_xros.sh
    ./build_plugin_xros.sh

    #for testing in mac os / editor:
    ./build_webrtc_mac.sh
    ./build_plugin_mac.sh
        
    #sync the build plugin folder and the test project
    ./sync.sh


## Testing
Open the unity project at ./uwrtc_testproj.
The project is set up to work with the vision os simulator. For this it will load the plugin from
./uwrtc_testproj/Assets/webrtc/Runtime/Plugins/simxros

To build for the vision pro device rename the folder "simxros" to "simxros~" and then include the device specific plugin by renaming "xros~" to "xros". 
