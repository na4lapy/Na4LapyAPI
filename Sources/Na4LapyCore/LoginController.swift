//
//  LoginController.swift
//  Na4lapyAPI
//
//  Created by scoot on 04.01.2017.
//
//

import Kitura
import LoggerAPI
import Foundation
import SwiftyJSON
import KituraSession

public class LoginController {
    public let router = Router()
    private let db: DBLayer
    
    public init(db: DBLayer) {
        self.db = db
        setup()
    }
    
    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.post("", handler: onPost)
    }
    
    //
    // MARK: obsługa requestów
    //
    
    private func onPost(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            var data = Data()
            _ = try request.read(into: &data)
            let json = JSON(data: data).dictionaryObject ?? [:]

            guard let email = json["email"] as? String,
                let password = json["password"] as? String else {
                    response.status(.forbidden)
                    try? response.end()
                    Log.error("Zły login lub hasło")
                    return
            }
            let shelterId = try db.checkLogin(email: email, password: password)
            let sess = request.session
            sess?[SecUserDBKey.shelterid] = JSON(shelterId)
            try response.status(.OK).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.forbidden)
            try? response.end()
        }        
    }
}
