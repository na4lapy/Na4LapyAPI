//
//  Controller.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Kitura
import SwiftyJSON
import LoggerAPI
import KituraSession
import Foundation

public class AnimalController: SessionCheckable {
    public let backend: AnimalBackend
    public let router = Router()

    //
    // MARK: inicjalizacja
    //
    
    public init(backend: AnimalBackend) {
        self.backend = backend
        setup()
    }

    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.get("", handler: onGetWithParams)
        router.get("/:id", handler: onGetbyId)
        router.post("", handler: onPost)
        router.post("/getbyids", handler: onPostGetByIds)
        router.patch("", handler: onPatch)
        router.delete("/:id", handler: onDelete)
    }
    
    //
    // MARK: obsługa requestów
    //
    private func onPostGetByIds(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        var data = Data()
        
        do {
            _ = try request.read(into: &data)
            let json = JSON(data: data).dictionaryObject ?? [:]
            if let ids = json["ids"] as? [Int] {
                let result = try backend.get(byIds: ids)
                response.headers.append(ResponseHeader.cacheControl, value: ResponseHeader.cacheControlValue)
                try response.status(.OK).send(json: JSON(result)).end()
            } else {
                throw ResultCode.AnimalBackendNoData
            }
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
        }
    }
    
    private func onDelete(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"], let intId = Int(id) else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.end()
            return
        }

        do {
            let sessShelterid = try checkSession(request: request, response: response)
            //
            // TODO: pobrać shelterid dla wskazanego id i sprawdzić uprawnienia
            //
            _ = try backend.delete(byId: intId)
            try response.status(.OK).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
        }
    }
    
    private func onPatch(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        var data = Data()

        do {
            let sessShelterid = try checkSession(request: request, response: response)
            _ = try request.read(into: &data)
            let json = JSON(data: data).dictionaryObject ?? [:]
            guard let shelterid = json[AnimalJSON.shelterid] as? Int else {
                throw ResultCode.AuthorizationError
            }
            if sessShelterid != shelterid {
                throw ResultCode.AuthorizationError
            }
            let id = try backend.edit(withDictionary: json)
            try response.status(.OK).send(json: JSON(["id" : id])).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError).send(json: JSON(error.localizedJsonString))
            try? response.end()
        }
    }

    private func onPost(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        var data = Data()

        do {
            let sessShelterid = try checkSession(request: request, response: response)
            _ = try request.read(into: &data)
            let json =  JSON(data: data).dictionaryObject ?? [:]
            guard let shelterid = json[AnimalJSON.shelterid] as? Int else {
                throw ResultCode.AuthorizationError
            }
            if sessShelterid != shelterid {
                throw ResultCode.AuthorizationError
            }
            let id = try backend.add(withDictionary: json)
            try response.status(.OK).send(json: JSON(["id" : id])).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError).send(json: JSON(error.localizedJsonString))
            try? response.end()
        }
    }
    
    /**
    Pobranie obiektu na podstawie identyfikatora
 
    */
    private func onGetbyId(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"], let intId = Int(id) else {
            Log.error("Brak parametru 'id' w zapytaniu.")
            try? response.end()
            return
        }
        
        do {
            let result = try backend.get(byId: intId)
            response.headers.append(ResponseHeader.cacheControl, value: ResponseHeader.cacheControlValue)
            try response.status(.OK).send(json: JSON(result)).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
        }
    }
    
    /**
    Pobranie obiektu na podstawie zakresu i/lub preferencji
 
    */
    private func onGetWithParams(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        let params = request.queryParameters
        var shelterid: Int? = nil
        
        if let sess = request.session, let sessShelterid = sess[SecUserDBKey.shelterid].string, let sid = Int(sessShelterid) {
            shelterid = sid
        }

        do {
            let result = try backend.getall(shelterid: shelterid, params: params)
            response.headers.append(ResponseHeader.cacheControl, value: ResponseHeader.cacheControlValue)
            try response.status(.OK).send(json: JSON(result)).end()
        } catch (let error) {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            try? response.end()
            return
        }

    }

}
