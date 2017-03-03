//
//  LogoutController.swift
//  Na4lapyAPI
//
//  Created by scoot on 11.01.2017.
//
//

import Kitura
import LoggerAPI
import Foundation
import SwiftyJSON

public class LogoutController {
    public let router = Router()
    
    public init() {
        setup()
    }
    
    //
    // MARK: konfiguracja routerów
    //
    
    private func setup() {
        router.post("", handler: onGet)
    }
    
    //
    // MARK: obsługa requestów
    //
    
    private func onGet(request: RouterRequest, response: RouterResponse, next: () -> Void) {
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
}
