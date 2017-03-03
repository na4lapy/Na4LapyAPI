//
//  ShelterController.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 22/02/2017.
//
//

import Kitura
import LoggerAPI
import Foundation
import SwiftyJSON

public class ShelterController {
    public let router = Router()
    let backend: ShelterBackend

    public init(backend: ShelterBackend) {
        self.backend = backend
        setup()
    }


    /// MARK: konfiguracja routerów
    private func setup(){
        router.get("/:id", handler: onGetbyId)
        router.patch("", handler: onPatch)
    }

    private func onGetbyId(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"], let shelterId = Int(id) else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.end()
            return
        }

        do {
            let result = try backend.get(byId: shelterId)
            try response.status(.OK).send(json: JSON(result)).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.unauthorized)
            try? response.end()
            return
        }
    }

    private func onPatch(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        var data = Data()
        do {
            _ = try checkSession(request: request, response: response)

            _ = try request.read(into: &data)
            let json = JSON(data: data).dictionaryObject ?? [:]
            let id = try  backend.edit(withDictionary: json)

            try response.status(.OK).send(json: JSON(["id": id])).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError).send(json: JSON(error.localizedDescription))
            try? response.end()
        }
    }

    //TODO: THIS IS DUPLICATE NEED TO REFACTOR
    private func checkSession(request: RouterRequest, response: RouterResponse) throws -> Int {
        guard let sess = request.session, let shelterid = sess[SecUserDBKey.shelterid].string, let sessShelterid = Int(shelterid) else {
            Log.error("Wymagane uwierzytelnienie.")
            response.status(.forbidden)
            try? response.end()
            throw ResultCode.AuthorizationError
        }
        return sessShelterid
    }

}
