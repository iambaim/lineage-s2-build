#!/bin/bash

# Deploy certificates
cd
tar -zxvf android-certs.tgz

# Install pre-requisites
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt upgrade -y
apt install -y  bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python screen brotli
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=$PATH:${HOME}/bin

# Setup GIT
git config --global user.name "Unofficial Lineage buildbot"
git config --global user.email buildbot@s2.lineage
git config --global color.ui auto

# Get repo
mkdir -p ~/android/lineage
cd ~/android/lineage
repo init --depth=1 -u https://github.com/LineageOS/android.git -b lineage-16.0
mkdir .repo/local_manifests/

echo  -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\
\n<manifest>\
\n\t<project name=\"TheMuppets/proprietary_vendor_leeco\" path=\"vendor/leeco\"/>\
\n</manifest>" > .repo/local_manifests/local_manifest.xml

repo sync -c

source build/envsetup.sh
breakfast s2

mka target-files-package dist

croot
./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs \
    out/dist/*-target_files-*.zip \
    signed-target_files.zip

./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey \
    --block --backup=true \
    signed-target_files.zip \
    signed-ota_update.zip

