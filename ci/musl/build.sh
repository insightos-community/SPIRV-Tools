#!/bin/sh
set -eu
cd /work
mkdir -p logs build prefix dist
exec > logs/build.log 2>&1
apk add --no-cache build-base cmake ninja git binutils python3 patch linux-headers
apk info -v > logs/apk-packages.txt
git config --global --add safe.directory '*'
cp -a /src source
cd source
patch -p1 < /src/ci/musl/patches/spv-intel-function-variants-basic-asm-dis.patch
python utils/git-sync-deps --treeless > /work/logs/dependencies.log 2>&1
cd /work
cmake -S source -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/work/prefix -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_RPATH='$ORIGIN/../lib' -DSPIRV_SKIP_TESTS=OFF \
  -DBUILD_SHARED_LIBS=ON -DSPIRV_TOOLS_BUILD_STATIC=OFF -DSPIRV_WERROR=OFF \
  > logs/configure.log 2>&1
cmake --build build --parallel 2 > logs/compile.log 2>&1
ctest --test-dir build --output-on-failure --timeout 600 > logs/tests.log 2>&1
cmake --install build > logs/install.log 2>&1
python /src/ci/musl/package.py
