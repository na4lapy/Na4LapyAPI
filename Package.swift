import PackageDescription

let package = Package(
    name: "Na4lapyAPI",
    dependencies: [
            .Package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", majorVersion: 1, minor: 4),
            .Package(url: "https://github.com/scootpl/Na4lapyCore.git", majorVersion: 0, minor: 2)
     ]
)


