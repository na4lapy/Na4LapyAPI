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

public class SecUserController: SessionCheckable {
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
        router.post("/login", handler: onLogin)
        router.get("/logout", handler: onLogout)
        router.post("/change_password", handler: onPasswordChange)
        router.patch("/terms_of_use", handler: onTermsOfUseChange)
        router.get("/terms_of_use", handler: onTermsOfUseGet)
    }
    
    //
    // MARK: obsługa requestów
    //
    
    private func onLogin(request: RouterRequest, response: RouterResponse, next: () -> Void) {
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

    private func onLogout(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        let sess = request.session
        sess?.destroy{ _ in }

        do {
            try response.status(.OK).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
        }
    }

    private func onPasswordChange(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        //check sessions

        do {
            let shelterId = try checkSession(request: request, response: response)
            var data = Data()
            _ = try request.read(into: &data)
            let json = JSON(data: data)

            let secUser = try SecUser(withJSON: json)

            if let secUser = secUser {
               let updatedId =  try db.updatePassword(forUser: secUser, withShelterId: shelterId)

                try? response.status(.OK).send("\(updatedId)").end()
            } else {
                response.status(.unprocessableEntity).send("Could not create secUser")
            }

        } catch (let error) {
            //MARK: error check
            if let secUserError = error as? SecUserError {
                var errorJson: JSON?
                switch secUserError {
                case .missingParams(let json):
                    errorJson = json
                case .newPasswordAndRepeatNotTheSame(let json):
                    errorJson = json
                case .newPasswordSameAsOld(let json):
                    errorJson = json
                case .wrongOldPassword(let json):
                    errorJson = json
                default:
                    break
                }

                Log.error(errorJson.debugDescription)
                response.status(.unprocessableEntity)
                if let errorJson = errorJson {
                    response.send(json: errorJson)
                }

            }
        }

        try? response.end()

    }

    /// Called when panel is trying to accepts terms of use, SECURED BY COOKIE CHECK
    ///
    /// - Parameters:
    ///   - request: request should contain areTermsOfUseAccepted bool, value
    ///   - response: response
    ///   - next: func to call next
    private func onTermsOfUseChange(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            let shelterId = try checkSession(request: request, response: response)
            var data = Data()

            _ = try request.read(into: &data)
            let json = JSON(data: data)

            guard let areTermsOfUserAccepted = json["areTermsOfUseAccepted"].bool else {
                throw SecUserError.missingParams(JSON(["areTermsOfUseAccepted", JSON.missingParamJsonErrorString]))
            }

            let updatedId = try db.update(areTermsOfUseAccepted: areTermsOfUserAccepted, forShelterId: shelterId)

            try? response.status(.OK).send("\(updatedId)").end()

        } catch (let error) {

            if let secUserError = error as? SecUserError {
                var errorJson: JSON?
                switch secUserError {
                case .missingParams(let json):
                    errorJson = json
                default:
                    break
                }

            Log.error(error.localizedDescription)
            response.status(.unprocessableEntity)

            if let errorJson = errorJson {
                response.send(json: errorJson)
            }
        }

        try? response.end()

        }
    }

    private func onTermsOfUseGet(request: RouterRequest, response: RouterResponse, next: () -> Void) {

        do {
            let shelterId = try checkSession(request: request, response: response)

            let areTermsOfUseAccepterd = try db.areTermsOfUseAccepted(forShelterId: shelterId)

            try? response.status(.OK).send("\(areTermsOfUseAccepterd)").end()
        } catch (let error) {

            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
        }
    }


}
    

