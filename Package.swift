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
            path: "Source/CLibssh2",
            publicHeadersPath: "include",
            linkerSettings: [.linkedLibrary("ssl")]
        ),
        .binaryTarget(
            name: "libssh2",
            url: "https://github.com/swlfigo/libssh2-spm/releases/download/storage.1.11.102/libssh2.xcframework.zip",
            checksum: "4a0814533866e388b50ab9f071b2d968198c19f8825b638ea6705c44c20582fc"
        ),
    ]
)
