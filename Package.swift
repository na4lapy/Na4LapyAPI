import PackageDescription

let package = Package(
    name: "Na4lapyAPI",
    targets: [
        Target(name: "Server", dependencies: [.Target(name: "Na4LapyCore")]),
        Target(name: "Na4LapyCore")
    ],
    dependencies: [
            .Package(url: "https://github.com/IBM-Swift/Kitura-Session.git", majorVersion: 1),
            .Package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", majorVersion: 1),
            .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1),
            .Package(url: "https://github.com/vapor/postgresql", majorVersion: 1),
            .Package(url: "https://github.com/IBM-Swift/Kitura-MustacheTemplateEngine.git", majorVersion: 1),
            .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0)
     ]
)


