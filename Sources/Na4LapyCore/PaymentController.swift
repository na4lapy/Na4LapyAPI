//
//  File.swift
//  Na4lapyAPI
//
//  Created by Marek Kaluzny on 19.03.2017.
//
//
import CryptoSwift
import Kitura
import SwiftyJSON
import Foundation
import LoggerAPI

public class PaymentController {
    public let router = Router()
    private let shelterBackend: ShelterBackend
    private let merchant_id = "marek.kaluzny" //this should be retrieved from shelterDB
    private let salt = "la4cle6c" //this should be retrieved from shelterDB
    
    public init(shelterBackend: ShelterBackend) {
        self.shelterBackend = shelterBackend
        setup()
    }
    
    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.get("/form/shelter/:id", handler: onFormForShelter)
        router.get("/form/shelter/:id/finish", handler: onFinish)
        router.post("/hash", handler: onHash)
    }

    private func onFormForShelter(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            if let id = request.parameters["id"],
                let shelterId = Int(id),
                let shelter: Shelter = try shelterBackend.getShelter(byId: shelterId) {
                try response.render("Payments/PaymentForm", context: ["merchant_id": merchant_id, "back_url": request.originalURL + "/finish", "shelterName": shelter.name])
            } else {
                try! response.status(.internalServerError).send("Error: " + "Unable to get shelter details").end()
            }
        } catch (let error) {
            try! response.status(.internalServerError).send("Error: " + error.localizedDescription).end()
        }
    }
    
    private func onFinish(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            try response.render("Payments/PaymentFinishForm", context: [:])
        } catch (let error) {
            try! response.status(.internalServerError).send("Error: " + error.localizedDescription).end()
        }
    }
    
    private func onHash(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let parsedBody = request.body else {
            next()
            return
        }
        
        switch(parsedBody) {
        case .json(let json):
            let amount: String = json["amount"].stringValue
            let currency: String = json["currency"].stringValue
            let description: String = json["description"].stringValue
            let transaction_type: String = json["transaction_type"].stringValue
            let hash = self.calculateHash(salt: self.salt, description: description, amount: amount, currency: currency, transaction_type: transaction_type)
            
            try? response.status(.OK).send(json: JSON(["hash" : hash])).end()
        default:
            break
        }
        next()
    }
    
    private func calculateHash(salt: String, description: String, amount: String, currency: String, transaction_type: String) -> String {
        let pas: String = "\(self.salt)|\(description)|\(amount)|\(currency)|\(transaction_type)"
        let data = Data(Array(pas.utf8))
        
        return data.sha1().toHexString()
    }
}
