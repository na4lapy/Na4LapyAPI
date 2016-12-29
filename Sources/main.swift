//
//  main.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 22.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Kitura
import HeliumLogger
import LoggerAPI
import Foundation
import Na4lapyCore

HeliumLogger.use()

var dbconfig = DBConfig()

if let dbuser = getenv("N4L_API_DATABASE_USER") {
    dbconfig.user = String(cString: dbuser)
}
if let dbpass = getenv("N4L_API_DATABASE_PASS") {
    dbconfig.password = String(cString: dbpass)
}
let db = DBLayer(config: dbconfig)
let animalBackend = AnimalBackend(db: db)
let animalController = Controller(backend: animalBackend)

let mainRouter = Router()
mainRouter.get("/") {
    request, response, next in
    next()
}

mainRouter.all("animals", middleware: animalController.router)
//mainRouter.all("shelter", middleware: shelter)


//  an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8123, with: mainRouter)

// Start the Kitura runloop (this call never returns)
Kitura.run()

