#! /bin/bash

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: ${0} old_version new_version [old_build] [new_build]"
    echo "       (old_build and new_build parameters are optional and default to 1)"
    exit 1
fi

echo "Updating Ungoogled-Chromium Void from version ${1}-${3-1} to version ${2}-${4-1}..."

if [[ "$1" = "$2" ]]; then
    git checkout -q ${2} || { echo "Unable to checkout branch ${2}"; exit 2; }
else
    git checkout -q origin/${1} -b ${2} || { echo "Unable to create branch ${2} from {$1}"; exit 2; }
fi

sed -i "s/version=${1}/version=${2}/" void-packages/srcpkgs/ungoogled-chromium/template
sed -i "s/revision=${3-1}/revision=${4-1}/" void-packages/srcpkgs/ungoogled-chromium/template

wget -q https://github.com/chromium-linux-tarballs/chromium-tarballs/releases/download/${1}/chromium-${1}-linux.tar.xz.hashes -P /tmp/ > /dev/null || { echo "Unable to download chromium-${1}-linux.tar.xz.hashes"; exit 3; }
OLD_CHROMIUM_HASH=`cat /tmp/chromium-${1}-linux.tar.xz.hashes | grep 'sha256' | awk '{print $2}'`
rm /tmp/chromium-${1}-linux.tar.xz.hashes

wget -q https://github.com/chromium-linux-tarballs/chromium-tarballs/releases/download/${2}/chromium-${2}-linux.tar.xz.hashes -P /tmp/ > /dev/null || { echo "Unable to download chromium-${2}-linux.tar.xz.hashes"; exit 4; }
CHROMIUM_HASH=`cat /tmp/chromium-${2}-linux.tar.xz.hashes | grep 'sha256' | awk '{print $2}'`
rm /tmp/chromium-${2}-linux.tar.xz.hashes

sed -i "s/$OLD_CHROMIUM_HASH/$CHROMIUM_HASH/" void-packages/srcpkgs/ungoogled-chromium/template

wget -q https://github.com/ungoogled-software/ungoogled-chromium/archive/refs/tags/${1}-${3-1}.tar.gz -P /tmp/ > /dev/null || { echo "Unable to download ${1}-${3-1}.tar.gz"; exit 5; }
OLD_UNGOOGLED_HASH=`sha256sum /tmp/${1}-${3-1}.tar.gz | awk '{print $1}'`
rm /tmp/${1}-${3-1}.tar.gz

wget -q https://github.com/ungoogled-software/ungoogled-chromium/archive/refs/tags/${2}-${4-1}.tar.gz -P /tmp/ > /dev/null || { echo "Unable to download ${2}-${4-1}.tar.gz"; exit 6; }
UNGOOGLED_HASH=`sha256sum /tmp/${2}-${4-1}.tar.gz | awk '{print $1}'`
rm /tmp/${2}-${4-1}.tar.gz

sed -i "s/$OLD_UNGOOGLED_HASH/$UNGOOGLED_HASH/" void-packages/srcpkgs/ungoogled-chromium/template

UGC=`pwd`

cd ..

[[ ! -d void-packages ]] && git clone --depth=1 https://github.com/void-linux/void-packages.git

cd void-packages
git reset -q --hard HEAD
git clean -q -f
git fetch -q
git pull -q

CHROMIUM_HASH=`git log -i -n 1 --all-match --grep 'chromium' --grep "${2}" --pretty=format:"%H"`

if [[ -z $CHROMIUM_HASH ]]; then
    IFS='.' read -r -a version <<< "${2}"
    CHROMIUM_HASH=`git log -i -n 1 --all-match --grep 'chromium' --grep "${version[0]}.${version[1]}.${version[2]}" --pretty=format:"%H"`

    if [[ -z $CHROMIUM_HASH ]]; then
        echo "Could not find chromium ${2} commit in void-packages"
        exit 7
    fi
fi

git checkout -q $CHROMIUM_HASH

cp -r srcpkgs/chromium/patches $UGC/void-packages/srcpkgs/ungoogled-chromium/

# remove redundant patches
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-130-hardware_destructive_interference_size.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/cr138-musl-gtk-serinfo.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-119-fix-aarch64-musl.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-revert-drop-of-system-java.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/fc-cache-version.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-138-musl-toolchain.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-140-8393b61.patch
rm -f $UGC/void-packages/srcpkgs/ungoogled-chromium/patches/chromium-140-8393b61.patch.args

git checkout -q master


cd $UGC

git add -A
git commit -q -m "${2}-${4-1}"

LATEST_COMMIT=`git log -n 1 --pretty=format:"%H"`
git checkout -q master
git fetch -q
git pull -q
git cherry-pick $LATEST_COMMIT
git push -q

echo "Pushed ${2}-${4-1} to master ($LATEST_COMMIT)"


git checkout -q ${2}

sed -i "s/${1}_${3-1}/${2}_${4-1}/" version

git add -A
git commit -q -m "${2}-${4-1}"
git push -q --set-upstream origin ${2}

echo "Pushed ${2}-${4-1} to upstream"

git checkout -q master
