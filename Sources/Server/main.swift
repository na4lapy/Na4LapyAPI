//
//  main.swift
//  na4lapy-api
//
//  Created by Wojciech Bilicki on 02/03/2017.
//
//

import Foundation

import SwiftyJSON
import Kitura
import HeliumLogger
import LoggerAPI
import Foundation
import KituraCORS
import KituraSession
import KituraMustache
import Na4LapyCore

HeliumLogger.use()

var dbconfig = DBConfig()
var animalBackend: AnimalBackend
let defaultListenPort = 8123
var defaultImagesPath = ""
var listenPort: Int = defaultListenPort

// Session
//
let session = Session(secret: UUID().uuidString)

// CORS
//
let options = Options(allowedOrigin: .origin("https://panel.na4lapy.org"), credentials: true, methods: ["GET","PUT", "PATCH", "DELETE"], allowedHeaders: ["Content-Type", "kitura-session-id"], maxAge: 5)
let cors = CORS(options: options)

// FIXME: ścieżki powinny być zakończone znakiem slash
//
if let imagesPath = getenv("N4L_API_IMAGES_PATH") {
    defaultImagesPath = String(cString: imagesPath)
    Log.info("Ścieżka do zdjęć: \(defaultImagesPath)")
}
if let dbname = getenv("N4L_API_DATABASE_NAME") {
    dbconfig.dbname = String(cString: dbname)
}
if let dbuser = getenv("N4L_API_DATABASE_USER") {
    dbconfig.user = String(cString: dbuser)
}
if let dbpass = getenv("N4L_API_DATABASE_PASS") {
    dbconfig.password = String(cString: dbpass)
}
if let oldapi = getenv("N4L_OLDAPI_IMAGES_URL") {
    dbconfig.oldapiUrl = String(cString: oldapi)
}
if let apiport = getenv("N4L_API_LISTEN_PORT") {
    listenPort = String(cString: apiport).int ?? defaultListenPort
}

let db = DBLayer(config: dbconfig)

//if let oldapi = getenv("N4L_OLDAPI_IMAGES_URL") {
//    Log.info("Uruchomienie w trybie OLD_API, url: \(dbconfig.oldapiUrl)")
//    animalBackend = AnimalBackend_oldapi(db: db)
//} else {
    animalBackend = AnimalBackend(db: db)
//}
let photoBackend = PhotoBackend(db: db)


let shelterBackend = ShelterBackend(db: db)

let animalController = AnimalController(backend: animalBackend)
let filesController = FilesController(path: defaultImagesPath, backend: photoBackend)
let loginController = SecUserController(db: db)
let shelterController = ShelterController(backend: shelterBackend)
let paymentController = PaymentController(merchant_id: "to_change", salt: "to_change")

let mainRouter = Router()
mainRouter.add(templateEngine: MustacheTemplateEngine())
mainRouter.setDefault(templateEngine: MustacheTemplateEngine())

mainRouter.get("/") {
    request, response, next in
    next()
}

mainRouter.all(middleware: BodyParser())
mainRouter.all("auth", middleware: session)
mainRouter.all("animals", middleware: session)
mainRouter.all("files", middleware: session)
mainRouter.all("shelter", middleware: session)

mainRouter.all("auth", middleware: cors)
mainRouter.all("animals", middleware: cors)
mainRouter.all("files", middleware: cors)
mainRouter.all("shelter", middleware: cors)

mainRouter.all("animals", middleware: animalController.router)
mainRouter.all("files", middleware: filesController.router)
mainRouter.all("auth", middleware: loginController.router)
mainRouter.all("shelter", middleware: shelterController.router)
mainRouter.all("payment", middleware: paymentController.router)
//  an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: listenPort, with: mainRouter)

// Start the Kitura runloop (this call never returns)
Kitura.run()
