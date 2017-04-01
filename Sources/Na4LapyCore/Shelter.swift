//
//  Shelter.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 23.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import SwiftyJSON
import Foundation
import PostgreSQL

struct Shelter {
    //TODO: Obsługa statusu active?
    private(set) var id: Int
    var name: String
    private var street: String?
    private var buildingNumber: Int?
    private var city: String?
    private var postalCode: String?
    private var voivodeship: String?
    private var email: String?
    private var phoneNumber: String?
    private var website: String?
    private var facebookProfile: String?
    private var accountNumber: String?
    private var adoptionRules: String?

    init?(dictionary: DBEntry) {
        guard
            let id = dictionary[ShelterDBKey.id]?.int,
            let name = dictionary[ShelterDBKey.name]?.string
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.street = dictionary[ShelterDBKey.street]?.string
        self.buildingNumber = dictionary[ShelterDBKey.building_number]?.int
        self.city = dictionary[ShelterDBKey.city]?.string
        self.postalCode = dictionary[ShelterDBKey.postal_code]?.string
        self.voivodeship = dictionary[ShelterDBKey.voivodeship]?.string
        self.email = dictionary[ShelterDBKey.email]?.string
        self.phoneNumber = dictionary[ShelterDBKey.phone_number]?.string
        self.website = dictionary[ShelterDBKey.website]?.string
        self.facebookProfile = dictionary[ShelterDBKey.facebook_profile]?.string
        self.accountNumber = dictionary[ShelterDBKey.account_number]?.string
        self.adoptionRules = dictionary[ShelterDBKey.adoption_rules]?.string

    }

    init?(withJSON json: JSONDictionary) {
        guard
            let id = json[ShelterJSON.id] as? Int,
            let name = json[ShelterJSON.name] as? String else {
                return nil
        }

        self.id = id
        self.name = name
        self.street = json[ShelterJSON.street] as? String
        self.buildingNumber = json[ShelterJSON.building_number] as? Int
        self.city = json[ShelterJSON.city] as? String
        self.postalCode = json[ShelterJSON.postal_code] as? String
        self.voivodeship = json[ShelterJSON.voivodeship] as? String
        self.email = json[ShelterJSON.email] as? String
        self.phoneNumber = json[ShelterJSON.phone_number] as? String
        self.website = json[ShelterJSON.website] as? String
        self.facebookProfile = json[ShelterJSON.facebook_profile] as? String
        self.accountNumber = json[ShelterJSON.account_number] as? String
        self.adoptionRules = json[ShelterJSON.adoption_rules] as? String

    }


    func dictionaryRepresentation() -> JSONDictionary {

        let street = self.street ?? ""
        let buildingNumber = self.buildingNumber ?? -1
        let city = self.city ?? ""
        let postalCode = self.postalCode ?? ""
        let voivodeship = self.voivodeship ?? ""
        let email = self.email ?? ""
        let phoneNumber = self.phoneNumber ?? ""
        let website = self.website ?? ""
        let facebookProfile = self.facebookProfile ?? ""
        let accountNumber = self.accountNumber ?? ""
        let adoptionRules = self.adoptionRules ?? ""

        let dict: JSONDictionary = [
            ShelterJSON.id : self.id,
            ShelterJSON.name  : self.name,
            ShelterJSON.street : street,
            ShelterJSON.building_number : buildingNumber,
            ShelterJSON.city : city,
            ShelterJSON.postal_code : postalCode,
            ShelterJSON.voivodeship : voivodeship,
            ShelterJSON.email : email,
            ShelterJSON.phone_number : phoneNumber,
            ShelterJSON.website : website,
            ShelterJSON.facebook_profile : facebookProfile,
            ShelterJSON.account_number : accountNumber,
            ShelterJSON.adoption_rules : adoptionRules
        ]
        return dict

    }

    func dbRepresentation() -> DBEntry {
        let name = self.name.makeNode()
        let street = self.street?.makeNode() ?? Node.null
        let buildingNumber = try? self.buildingNumber?.makeNode() ?? Node.null
        let city = self.city?.makeNode() ?? Node.null
        let postalCode = self.postalCode?.makeNode() ?? Node.null
        let voivodeship = self.voivodeship?.makeNode() ?? Node.null
        let email = self.email?.makeNode() ?? Node.null
        let phoneNumber = self.phoneNumber?.makeNode() ?? Node.null
        let website = self.website?.makeNode() ?? Node.null
        let facebookProfile = self.facebookProfile?.makeNode() ?? Node.null
        let accountNumber = self.accountNumber?.makeNode() ?? Node.null
        let adoptionRules = self.adoptionRules?.makeNode() ?? Node.null

        let dbEntry: DBEntry = [
            ShelterDBKey.id : Node(self.id),
            ShelterDBKey.name : name,
            ShelterDBKey.street : street,
            ShelterDBKey.building_number : buildingNumber ?? Node.null,
            ShelterDBKey.city : city,
            ShelterDBKey.postal_code : postalCode,
            ShelterDBKey.voivodeship : voivodeship,
            ShelterDBKey.email : email,
            ShelterDBKey.phone_number : phoneNumber,
            ShelterDBKey.website : website,
            ShelterDBKey.facebook_profile : facebookProfile,
            ShelterDBKey.account_number : accountNumber,
            ShelterDBKey.adoption_rules : adoptionRules
        ]

        return dbEntry

    }
}
