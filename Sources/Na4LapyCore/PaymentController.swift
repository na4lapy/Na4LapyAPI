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
    private let salt: String
    private let merchant_id: String
    
    public init(merchant_id: String, salt: String) {
        self.merchant_id = merchant_id
        self.salt = salt
        
        setup()
    }
    
    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.get("/form", handler: onForm)
        router.get("/form/finish", handler: onFinish)
        router.post("/hash", handler: onHash)
    }
    
    private func onForm(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            try response.render("/Payments/PaymentForm", context: ["merchant_id": merchant_id, "back_url": request.originalURL + "/finish"])
        } catch (let error) {
            try! response.status(.internalServerError).send("Error: " + error.localizedDescription).end()
        }
    }
    
    private func onFinish(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        do {
            try response.render("/Payments/PaymentFinishForm", context: [:])
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
