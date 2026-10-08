// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CLibssh2",
    products: [
        .library(name: "CLibssh2", targets: ["CLibssh2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swlfigo/openssl-spm", from: "4.0.3"),
    ],
    targets: [
        .target(
            name: "CLibssh2",
            dependencies: [
                "libssh2",
                .product(name: "OpenSSL", package: "openssl-spm"),
            ],
            path: "Source/CLibssh2"
        ),
        .binaryTarget(
            name: "libssh2",
            url: "https://github.com/swlfigo/libssh2-spm/releases/download/storage.1.11.100/libssh2.xcframework.zip",
            checksum: "cb4d5825e6b15c49e622e59860e6ab0716cf1b20244d1361e718c41b42377f90"
        ),
    ]
)
