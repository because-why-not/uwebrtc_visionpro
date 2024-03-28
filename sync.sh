#--exclude 'Plugins/xros/'
rsync -rav --delete ./com.unity.webrtc/Runtime/ ./uwrtc_testproj/Assets/webrtc/Runtime 
#rsync -rav ./com.unity.webrtc/Samples~/ ./uwrtc_testproj/Assets/Samples

