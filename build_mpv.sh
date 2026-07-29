#!/bin/bash
set -e

export PATH="/mingw64/bin:/usr/bin:$PATH"
export PKG_CONFIG_PATH="/c/Develop/Desktop/mpv/install/lib/pkgconfig:/mingw64/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="/c/Develop/Desktop/mpv/install/lib/pkgconfig:/mingw64/lib/pkgconfig"
WORKDIR="/c/Develop/Desktop/mpv"
JOBS=$(nproc)

echo "=== Building mpv ==="

cd "$WORKDIR/src/mpv"
rm -rf build

meson setup build \
    --prefix="$WORKDIR/install" \
    --buildtype=release \
    --strip \
    --default-library=static \
    --prefer-static \
    -Dc_link_args="-static" \
    -Dcpp_link_args="-static" \
    -Db_lto=true \
    -Dgpl=true \
    -Dcplayer=true \
    -Dlibmpv=false \
    -Dtests=false \
    -Dhtml-build=disabled \
    -Dmanpage-build=disabled \
    -Dpdf-build=disabled \
    -Dgl=disabled \
    -Dvulkan=disabled \
    -Dd3d11=disabled \
    -Ddirect3d=disabled \
    -Dsdl2-audio=disabled \
    -Dsdl2-gamepad=disabled \
    -Dsdl2-video=disabled \
    -Djpeg=disabled \
    -Dlibavdevice=disabled \
    -Dlua=disabled \
    -Djavascript=disabled \
    -Dcplugins=disabled \
    -Dsubrandr=disabled \
    -Dzimg=disabled \
    -Dvapoursynth=disabled \
    -Drubberband=disabled \
    -Dlcms2=disabled \
    -Dlibarchive=disabled \
    -Ddvdnav=disabled \
    -Dlibbluray=disabled \
    -Duchardet=disabled \
    -Dcaca=disabled \
    -Ddrm=disabled \
    -Dwayland=disabled \
    -Dx11=disabled \
    -Dspirv-cross=disabled \
    -Dshaderc=disabled \
    -Dd3d-hwaccel=disabled \
    -Dd3d9-hwaccel=disabled \
    -Dios-gl=disabled \
    -Dcocoa=disabled \
    -Dcoreaudio=disabled \
    -Dpulse=disabled \
    -Dpipewire=disabled \
    -Djack=disabled \
    -Dopenal=disabled \
    -Doss-audio=disabled \
    -Dalsa=disabled \
    -Dsndio=disabled \
    -Daudiounit=disabled \
    -Dswift-build=disabled \
    -Dplain-gl=disabled \
    -Dcuda-hwaccel=disabled \
    -Dcuda-interop=disabled \
    -Dsixel=disabled \
    -Degl=disabled \
    -Dxv=disabled

echo "Building mpv..."
ninja -C build -j$JOBS

echo ""
echo "=== Build Complete ==="
cp build/mpv.exe "$WORKDIR/mpv.exe"
ls -la "$WORKDIR/mpv.exe"

echo ""
echo "=== Required DLLs ==="
ldd "$WORKDIR/mpv.exe" 2>&1 | grep -i mingw64 || echo "No mingw64 DLLs (good for static)"

echo ""
echo "=== Testing ==="
"$WORKDIR/mpv.exe" --version || true
echo ""
"$WORKDIR/mpv.exe" --ao=help 2>&1 || true
echo ""
"$WORKDIR/mpv.exe" --ad=help 2>&1 | head -20 || true
