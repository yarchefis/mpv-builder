#!/bin/bash
set -e

export PATH="/mingw64/bin:$PATH"
export PKG_CONFIG_PATH="/mingw64/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="/mingw64/lib/pkgconfig"
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="$WORKDIR/install"
JOBS=$(nproc)

echo "=== Build environment ==="
echo "GCC: $(gcc --version | head -1)"
echo "Jobs: $JOBS"
echo "Prefix: $PREFIX"

mkdir -p "$PREFIX"/{lib,include,bin}
mkdir -p "$WORKDIR/src"

# ============================================
# Step 1: Clone and build FFmpeg (minimal audio-only)
# ============================================
echo ""
echo "=========================================="
echo "=== Step 1: Building FFmpeg ==="
echo "=========================================="

cd "$WORKDIR/src"
if [ ! -d "ffmpeg" ]; then
    echo "Cloning FFmpeg..."
    git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
fi

cd ffmpeg

# Clean previous build if exists
make distclean 2>/dev/null || true

echo "Configuring FFmpeg (minimal audio-only)..."
./configure \
    --prefix="$PREFIX" \
    --enable-static \
    --disable-shared \
    --enable-nonfree \
    --enable-version3 \
    --enable-small \
    --enable-stripping \
    --disable-debug \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-programs \
    --disable-ffmpeg \
    --disable-ffprobe \
    --disable-ffplay \
    --disable-network \
    --enable-network \
    --enable-openssl \
    --disable-avdevice \
    --disable-hwaccels \
    --disable-encoders \
    --disable-muxers \
    --disable-devices \
    --disable-decoders \
    --enable-decoder=flac \
    --enable-decoder=mp3,mp3float,mp3on4,mp3on4float \
    --enable-decoder=aac,aac_fixed,aac_latm \
    --enable-decoder=alac \
    --enable-decoder=pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_f64le \
    --enable-decoder=pcm_s16be,pcm_s24be,pcm_s32be,pcm_f32be \
    --enable-decoder=pcm_u8 \
    --enable-decoder=pcm_alaw,pcm_mulaw \
    --enable-decoder=wavpack \
    --enable-decoder=opus \
    --enable-decoder=vorbis \
    --disable-demuxers \
    --enable-demuxer=flac \
    --enable-demuxer=mp3 \
    --enable-demuxer=aac \
    --enable-demuxer=mov \
    --enable-demuxer=matroska \
    --enable-demuxer=ogg \
    --enable-demuxer=wav \
    --enable-demuxer=concat \
    --enable-demuxer=hls \
    --enable-demuxer=dash \
    --enable-demuxer=pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le \
    --enable-demuxer=ape \
    --enable-demuxer=wv \
    --enable-demuxer=dsf \
    --enable-demuxer=dff \
    --disable-parsers \
    --enable-parser=flac \
    --enable-parser=mpegaudio \
    --enable-parser=aac,aac_latm \
    --enable-parser=opus \
    --enable-parser=vorbis \
    --disable-filters \
    --enable-filter=aresample \
    --enable-filter=aformat \
    --enable-filter=anull \
    --enable-filter=atrim \
    --enable-filter=volume \
    --disable-protocols \
    --enable-protocol=file \
    --enable-protocol=http \
    --enable-protocol=https \
    --enable-protocol=tcp \
    --enable-protocol=tls \
    --enable-protocol=pipe \
    --enable-protocol=crypto \
    --enable-protocol=hls \
    --enable-protocol=concat \
    --disable-bsfs \
    --disable-indevs \
    --disable-outdevs \
    --extra-cflags="-Os -ffunction-sections -fdata-sections" \
    --extra-ldflags="-Wl,--gc-sections -static" \
    --extra-libs="-lws2_32 -lgdi32 -lcrypt32"

echo "Building FFmpeg..."
make -j$JOBS
make install

echo "FFmpeg built successfully!"
ls -la "$PREFIX/lib/"*.a

# ============================================
# Step 2: Clone and build mpv (minimal audio-only)
# ============================================
echo ""
echo "=========================================="
echo "=== Step 2: Building mpv ==="
echo "=========================================="

cd "$WORKDIR/src"
if [ ! -d "mpv" ]; then
    echo "Cloning mpv..."
    git clone --depth 1 https://github.com/mpv-player/mpv.git mpv
fi

cd mpv

# Set pkg-config to find our FFmpeg
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:/mingw64/lib/pkgconfig"

echo "Configuring mpv (minimal audio-only)..."
# Remove old build dir if exists
rm -rf build

meson setup build \
    --prefix="$PREFIX" \
    --buildtype=release \
    --strip \
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
echo "=========================================="
echo "=== Build Complete ==="
echo "=========================================="

# Copy the final binary
cp build/mpv.exe "$WORKDIR/mpv.exe"

echo ""
echo "=== Final mpv.exe ==="
ls -la "$WORKDIR/mpv.exe"

echo ""
echo "=== Required DLLs ==="
ldd "$WORKDIR/mpv.exe" | grep mingw64

echo ""
echo "=== Testing ==="
"$WORKDIR/mpv.exe" --version || true
echo ""
"$WORKDIR/mpv.exe" --ao=help 2>&1 || true
echo ""
"$WORKDIR/mpv.exe" --ad=help 2>&1 | head -20 || true
