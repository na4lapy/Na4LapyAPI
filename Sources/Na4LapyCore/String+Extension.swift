//
//  String+Extension.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 20/03/2017.
//
//

import Foundation

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
