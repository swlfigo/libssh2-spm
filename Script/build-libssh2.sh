#!/bin/bash
set -e
SOURCE_DIR=$1 SDK=$2 SYSTEM_NAME=$3 ARCHS=$4 MIN=$5 OSSL_SLICE=$6 DEST=$7
HERE=$(cd "$(dirname "$0")/.." && pwd)
OSSL_LIB=$(ls "$OSSL_SLICE"/*.a | head -1)   # ssl.a: contains libssl + libcrypto
OSSL_INC=$OSSL_SLICE/Headers
[ -f "$OSSL_INC/openssl/evp.h" ] || { echo "[!] openssl headers missing in $OSSL_INC"; exit 1; }
# FindOpenSSL wants two library names; same archive serves both.
mkdir -p "$DEST-ossl"
cp "$OSSL_LIB" "$DEST-ossl/libssl.a"; cp "$OSSL_LIB" "$DEST-ossl/libcrypto.a"

BDIR=$DEST-cmake
rm -rf "$BDIR" "$DEST"; mkdir -p "$DEST/lib" "$DEST/include"
ARCH_LIST=${ARCHS// /;}
echo "[*] libssh2: $SDK [$ARCH_LIST] min $MIN"
cmake -S "$SOURCE_DIR" -B "$BDIR" -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=$SYSTEM_NAME \
  -DCMAKE_OSX_SYSROOT=$SDK \
  -DCMAKE_OSX_ARCHITECTURES="$ARCH_LIST" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON \
  -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF \
  -DCRYPTO_BACKEND=OpenSSL \
  -DENABLE_ZLIB_COMPRESSION=OFF \
  -DLIBSSH2_NO_DEPRECATED=OFF \
  -DOPENSSL_INCLUDE_DIR="$OSSL_INC" \
  -DOPENSSL_SSL_LIBRARY="$DEST-ossl/libssl.a" \
  -DOPENSSL_CRYPTO_LIBRARY="$DEST-ossl/libcrypto.a"
cmake --build "$BDIR" --parallel 4 --target libssh2_static 2>&1 | tail -20 || true
LIB=$(find "$BDIR" -name 'libssh2*.a' | head -1)
[ -n "$LIB" ] || { echo "[!] libssh2.a not produced"; exit 1; }
cp "$LIB" "$DEST/lib/libssh2.a"
cp "$SOURCE_DIR"/include/*.h "$DEST/include/"
lipo -info "$DEST/lib/libssh2.a"
