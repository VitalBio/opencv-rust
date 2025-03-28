#!/bin/bash

set -vex

# remove system vcpkg
rm -rf "$VCPKG_INSTALLATION_ROOT"
export VCPKG_ROOT="$HOME/build/vcpkg"
if [[ -e "$VCPKG_ROOT" && ! -e "$VCPKG_ROOT/.git" ]]; then
	rm -rf "$VCPKG_ROOT"
fi
if [ ! -e "$VCPKG_ROOT" ]; then
	git clone https://github.com/Microsoft/vcpkg.git "$VCPKG_ROOT"
fi
pushd "$VCPKG_ROOT"
git fetch --all --prune --tags
git status
git checkout .
git checkout "$VCPKG_VERSION"
./bootstrap-vcpkg.sh -disableMetrics
#./vcpkg integrate install
echo "set(VCPKG_BUILD_TYPE release)" >> triplets/x64-windows.cmake
echo "set(VCPKG_BUILD_TYPE release)" >> triplets/x64-windows-static.cmake
echo "set(VCPKG_BUILD_TYPE release)" >> triplets/x86-windows.cmake
export VCPKG_DEFAULT_TRIPLET=x64-windows
#./vcpkg install llvm  # takes very long time
choco install -y llvm --version "$CHOCO_LLVM_VERSION"

# workaround for https://github.com/microsoft/vcpkg/issues/28896
patch -p1 < "$GITHUB_WORKSPACE/ci/vcpkg-msys-patch.diff"

./vcpkg install --recurse "opencv[contrib,nonfree]"
popd
