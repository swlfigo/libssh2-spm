#!/bin/bash
# Usage: build.sh <libssh2-commit-or-tag> <openssl-spm-storage-tag>
set -e
cd "$(dirname "$0")/.."
[ -f .root ] || { echo "[*] malformed project structure"; exit 1; }

LIBSSH2_REF=${1:?libssh2 ref required}
OPENSSL_STORAGE_TAG=${2:?openssl-spm storage tag required}
ROOT=$(pwd)
BUILD=$ROOT/build
mkdir -p "$BUILD"

echo "[*] fetching libssh2 @ $LIBSSH2_REF"
if [ ! -d "$BUILD/libssh2/.git" ]; then
  git clone https://github.com/libssh2/libssh2 "$BUILD/libssh2"
fi
git -C "$BUILD/libssh2" fetch --tags origin
git -C "$BUILD/libssh2" checkout -f "$LIBSSH2_REF"
SOURCE_DIR=$BUILD/libssh2

echo "[*] fetching openssl-spm $OPENSSL_STORAGE_TAG"
rm -rf "$BUILD/openssl" && mkdir -p "$BUILD/openssl"
curl -sSL --fail -o "$BUILD/openssl/libssl.xcframework.zip" \
  "https://github.com/swlfigo/openssl-spm/releases/download/$OPENSSL_STORAGE_TAG/libssl.xcframework.zip"
unzip -q "$BUILD/openssl/libssl.xcframework.zip" -d "$BUILD/openssl"
OSSL_XCF=$(find "$BUILD/openssl" -name "OpenSSL.Package.xcframework" -o -name "libssl.xcframework" | head -1)
echo "[*] openssl xcframework: $OSSL_XCF"

DEST=$BUILD/dest
rm -rf "$DEST"
# SOURCE SDK SYSTEM_NAME ARCHS MIN OSSL_SLICE DEST
# TODO: maccatalyst, tvOS, watchOS, visionOS
./Script/build-libssh2.sh "$SOURCE_DIR" macosx          Darwin "x86_64 arm64" 10.15 "$OSSL_XCF/macos-arm64_x86_64"            "$DEST/macosx"
./Script/build-libssh2.sh "$SOURCE_DIR" iphoneos        iOS    "arm64"        11.0  "$OSSL_XCF/ios-arm64_arm64e"              "$DEST/iphoneos"
./Script/build-libssh2.sh "$SOURCE_DIR" iphonesimulator iOS    "x86_64 arm64" 11.0  "$OSSL_XCF/ios-arm64_x86_64-simulator"    "$DEST/iphonesimulator"

CMD=()
for d in macosx iphoneos iphonesimulator; do
  CMD+=("-library" "$DEST/$d/lib/libssh2.a" "-headers" "$DEST/$d/include")
done
rm -rf "$BUILD/libssh2.xcframework" "$BUILD/libssh2.xcframework.zip"
xcodebuild -create-xcframework -output "$BUILD/libssh2.xcframework" "${CMD[@]}"
(cd "$BUILD" && zip -qr9 libssh2.xcframework.zip libssh2.xcframework)
echo "[*] done: $BUILD/libssh2.xcframework.zip"
