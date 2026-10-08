# libssh2-spm

Self-hosted Swift Package for [libssh2](https://github.com/libssh2/libssh2), built by GitHub Actions from upstream source into `libssh2.xcframework`.
Crypto backend is OpenSSL, **not bundled**: it links against [`swlfigo/openssl-spm`](https://github.com/swlfigo/openssl-spm).

## Usage

```swift
.package(url: "https://github.com/swlfigo/libssh2-spm", from: "1.11.101"),
// target dependency:
.product(name: "CLibssh2", package: "libssh2-spm"),
```

```swift
import CLibssh2
print(String(cString: libssh2_version(0)))
```

## Pinned version

Upstream has no release tag containing the fix for CVE-2026-55200 (transport.c packet-length bounds check, master commit `97acf3df`).
The build is therefore pinned to master commit `18aebe08962c1878d84c373ad85caff25ec67771` (descendant of `97acf3df`). Change `LIBSSH2_PIN` / `PACKAGE_VERSION` in `.github/workflows/build.yml` to roll forward; once an upstream release tag includes the fix, switch the pin to that tag.

## Platforms

macOS (x86_64, arm64), iOS (arm64), iOS Simulator (x86_64, arm64).
TODO: Mac Catalyst, tvOS, watchOS, visionOS.

## Build

`./Script/build.sh <libssh2-ref> <openssl-spm-storage-tag>` (requires Xcode + cmake). Compression (zlib) is disabled.
