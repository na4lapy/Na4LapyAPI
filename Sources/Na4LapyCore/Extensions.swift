//
//  Extensions.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 27.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Foundation

/**
Konwersja daty na String z uwzględnieniem formatowania

*/
extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Config.dateFormat
        return dateFormatter.string(from: self)
    }
}

/**
Zwracanie błędów w postaci Dictionary 
 
*/
extension Error {
    public func localizedJsonString() -> JSONDictionary {
        let result = [
            "error" : self.localizedDescription
        ]
        return result
    }
}

