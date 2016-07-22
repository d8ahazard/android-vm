#!/usr/bin/env bash

echo "Installing System Tools..."
sudo apt-get update -y >/dev/null 2>&1
sudo apt-get install -y curl >/dev/null 2>&1
sudo apt-get install -y unzip >/dev/null 2>&1
sudo apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 >/dev/null 2>&1
sudo apt-get update >/dev/null 2>&1
sudo apt-get install apt-file && apt-file update
sudo apt-get install -y python-software-properties >/dev/null 2>&1

#  http://askubuntu.com/questions/147400/problems-with-eclipse-and-android-sdk
sudo apt-get install -y ia32-libs >/dev/null 2>&1

echo "Installing Android NDK..."
cd /tmp
sudo curl -O http://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip
sudo unzip /tmp/android-ndk-r12b-linux-x86_64.zip -d /tmp/android-ndk-r12b
sudo mkdir -p /usr/local/android/ndk
sudo mv /tmp/android-ndk-r12b /usr/local/android/ndk
sudo rm -rf /tmp/android-ndk-r12b-linux-x86_64.zip
sudo chmod -R 755 /usr/local/android

echo "Updating ANDROID_HOME..."
cd ~/
cat << End >> .profile
export ANDROID_HOME="/home/androdev/Android/Sdk"
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
End


