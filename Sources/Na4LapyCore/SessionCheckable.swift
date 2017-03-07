//
//  SessionCheckable.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 04/03/2017.
//
//

import Foundation
import Kitura
import LoggerAPI

protocol SessionCheckable: class {
    func checkSession(request: RouterRequest, response: RouterResponse) throws -> Int
}


extension SessionCheckable {
    func checkSession(request: RouterRequest, response: RouterResponse) throws -> Int {
        guard let sess = request.session, let shelterid = sess[SecUserDBKey.shelterid].string, let sessShelterid = Int(shelterid) else {
            Log.error("Wymagane uwierzytelnienie.")
            response.status(.forbidden)
            try? response.end()
            throw ResultCode.AuthorizationError
        }
        return sessShelterid
    }

}
