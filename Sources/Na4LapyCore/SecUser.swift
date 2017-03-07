//
//  SecUser.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 04/03/2017.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI

struct SecUser {

    static let newPasswordKey = "newPassword"
    static let oldPasswordKey = "oldPassword"
    static let repeatNewPasswordKey = "repeatNewPassword"

    var newPassword: String?
    var oldPassword: String?
    var repeatNewPassword: String?

    init?(withJSON json: JSON) throws {
        guard
            let newPassword = json["newPassword"].string,
            let oldPassword = json["oldPassword"].string,
            let repeatNewPassword = json["repeatNewPassword"].string, !newPassword.isEmpty, !oldPassword.isEmpty, !repeatNewPassword.isEmpty else {
                throw SecUserError.missingParams(json.getMissingParams(forKeys: ["newPassword", "oldPassword", "repeatNewPassword"]))
        }

        guard newPassword != oldPassword else {
            throw SecUserError.newPasswordSameAsOld(JSON([SecUser.newPasswordKey: "Can't be same as old password"]))
        }

        guard newPassword == repeatNewPassword else  {
            throw SecUserError.newPasswordAndRepeatNotTheSame(JSON([SecUser.repeatNewPasswordKey: "Differs from newPassword"]))
        }

        self.newPassword = newPassword
        self.oldPassword = oldPassword
        self.repeatNewPassword = repeatNewPassword

    }
}

public enum SecUserError: Error {

    case missingParams(JSON)
    case newPasswordSameAsOld(JSON)
    case newPasswordAndRepeatNotTheSame(JSON)
    case wrongOldPassword(JSON)
    case badDbParams

    

}

extension JSON {

    static var missingParamJsonErrorString:String {
        get {
            return "Required parameter missing or invalid"
        }
    }

    func getMissingParams(forKeys keys: [String]) -> JSON {

        guard let jsonKeys = self.dictionary?.keys else {
            return JSON(keys.reduce([String: String](), { (dic, key)  in
                var ret = dic
                ret[key] = JSON.missingParamJsonErrorString
                return ret
                })
            )
        }

        let componentArray = Array(jsonKeys)

        return JSON(keys
            .filter { !componentArray.contains($0) || (componentArray.contains($0) && self[$0].string?.characters.count == 0) }
            .reduce([String: String](), { (dic, key) in
                var ret = dic
                ret[key] = JSON.missingParamJsonErrorString
                return ret
            })
        )
    }
}

