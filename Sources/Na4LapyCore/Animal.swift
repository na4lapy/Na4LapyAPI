//
//  Animal.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import SwiftyJSON
import Foundation
import PostgreSQL

struct Animal {
    var shelterId: Int
    private(set) var id: Int
    private var name: String
    private var race: String?
    private var description: String?
    private var birthDate: Date?
    private var admittanceDate: Date?
    private var chipId: String?
    private var sterilization: Sterilization?
    private var species: Species?
    private var gender: Gender?
    private var size: Size?
    private var activity: Activity?
    private var training: Training?
    private var vaccination: Vaccination?
    private var animalstatus: AnimalStatus?
    private var status: Status?
    private var calculatedPreferences: Double?
    var shelterName: String?
    
    init?(withJSON json: JSONDictionary, withShelterId shelterId: Int) {
        guard
            let shelterId = shelterId as? Int,
            let name = json[AnimalJSON.name] as? String else {
                return nil
        }
        if let id = json[AnimalJSON.id] as? Int {
            self.id = id
        } else {
            self.id = 0
        }

        self.shelterId = shelterId
        self.name = name
        self.race = json[AnimalJSON.race] as? String
        self.description = json[AnimalJSON.description] as? String
        
        if let birthdate = json[AnimalJSON.birthDate] as? String {
            //TODO: zmienić na lazy dateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Config.dateFormat
            self.birthDate = dateFormatter.date(from: birthdate)
        }
        
        if let admittancedate = json[AnimalJSON.admittanceDate] as? String {
            //TODO: zmienić na lazy dateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Config.dateFormat
            self.admittanceDate = dateFormatter.date(from: admittancedate)
        }
        
        self.chipId = json[AnimalJSON.chipId] as? String
        self.sterilization = Sterilization(rawValue: json[AnimalJSON.sterilization] as? String ?? "")
        self.species = Species(rawValue: json[AnimalJSON.species] as? String ?? "")
        self.gender = Gender(rawValue: json[AnimalJSON.gender] as? String ?? "")
        self.size = Size(rawValue: json[AnimalJSON.size] as? String ?? "")
        self.activity = Activity(rawValue: json[AnimalJSON.activity] as? String ?? "")
        self.training = Training(rawValue: json[AnimalJSON.training] as? String ?? "")
        self.vaccination = Vaccination(rawValue: json[AnimalJSON.vaccination] as? String ?? "")
        self.animalstatus = AnimalStatus(rawValue: json[AnimalJSON.animalstatus] as? String ?? "")
        self.status = Status(rawValue: json[AnimalJSON.status] as? String ?? "")
    }
    
    init?(dictionary: DBEntry) {
        guard
            let shelterId = dictionary[AnimalDBKey.shelterId]?.int,
            let id = dictionary[AnimalDBKey.id]?.int,
            let name = dictionary[AnimalDBKey.name]?.string
        else {
            return nil
        }
        self.shelterId = shelterId
        self.id = id
        self.name = name
        self.race = dictionary[AnimalDBKey.race]?.string
        self.description = dictionary[AnimalDBKey.description]?.string

        if let birthdate = dictionary[AnimalDBKey.birthDate]?.string {
            //TODO: zmienić na lazy dateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Config.dateFormat
            self.birthDate = dateFormatter.date(from: birthdate)
        }

        if let admittancedate = dictionary[AnimalDBKey.admittanceDate]?.string {
            //TODO: zmienić na lazy dateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Config.dateFormat
            self.admittanceDate = dateFormatter.date(from: admittancedate)
        }

        self.chipId = dictionary[AnimalDBKey.chipId]?.string
        self.sterilization = Sterilization(rawValue: dictionary[AnimalDBKey.sterilization]?.string ?? "")
        self.species = Species(rawValue: dictionary[AnimalDBKey.species]?.string ?? "")
        self.gender = Gender(rawValue: dictionary[AnimalDBKey.gender]?.string ?? "")
        self.size = Size(rawValue: dictionary[AnimalDBKey.size]?.string ?? "")
        self.activity = Activity(rawValue: dictionary[AnimalDBKey.activity]?.string ?? "")
        self.training = Training(rawValue: dictionary[AnimalDBKey.training]?.string ?? "")
        self.vaccination = Vaccination(rawValue: dictionary[AnimalDBKey.vaccination]?.string ?? "")
        self.animalstatus = AnimalStatus(rawValue: dictionary[AnimalDBKey.animalstatus]?.string ?? "")
        self.status = Status(rawValue: dictionary[AnimalDBKey.status]?.string ?? "")
        self.calculatedPreferences = dictionary[AnimalDBKey.calculatedPreferences]?.double
    }
    
    func dictionaryRepresentation() -> JSONDictionary {

        // workaround wycieku pamięci w SourceKitService
        //
        let race = self.race ?? ""
        let desc = self.description ?? ""
        let birth = self.birthDate?.toString() ?? ""
        let admitt = self.admittanceDate?.toString() ?? ""
        let chip = self.chipId ?? ""
        let ster = self.sterilization?.rawValue ?? ""
        let spec = self.species?.rawValue ?? ""
        let gend = self.gender?.rawValue ?? ""
        let size = self.size?.rawValue ?? ""
        let act = self.activity?.rawValue ?? ""
        let train = self.training?.rawValue ?? ""
        let vacc = self.vaccination?.rawValue ?? ""
        let stat1 = self.animalstatus?.rawValue ?? ""
        let stat2 = self.status?.rawValue ?? ""
        let shelterName = self.shelterName ?? ""
        
        var dict: JSONDictionary =
            [AnimalJSON.id : self.id,
             AnimalJSON.shelterid : self.shelterId,
             AnimalJSON.shelterName : shelterName,
             AnimalJSON.name : self.name,
             AnimalJSON.race : race,
             AnimalJSON.description : desc,
             AnimalJSON.birthDate : birth,
             AnimalJSON.admittanceDate : admitt,
             AnimalJSON.chipId : chip,
             AnimalJSON.sterilization : ster,
             AnimalJSON.species : spec,
             AnimalJSON.gender : gend,
             AnimalJSON.size : size,
             AnimalJSON.activity : act,
             AnimalJSON.training : train,
             AnimalJSON.vaccination : vacc,
             AnimalJSON.animalstatus : stat1,
             AnimalJSON.status : stat2,
        ]

        if let calcPrefs = self.calculatedPreferences {
            dict[AnimalJSON.calculatedPreferences] = calcPrefs
        }
        return dict
    }
    
    func dbRepresentation() -> DBEntry {

        // workaround wycieku pamięci w SourceKitService
        //
        
        let race = self.race?.makeNode() ?? Node.null
        let desc = self.description?.makeNode() ?? Node.null
        let birth = self.birthDate?.toString().makeNode() ?? Node.null
        let admitt = self.admittanceDate?.toString().makeNode() ?? Node.null
        let chip = self.chipId?.makeNode() ?? Node.null
        let ster = self.sterilization?.rawValue.makeNode() ?? Node.null
        let spec = self.species?.rawValue.makeNode() ?? Node.null
        let gend = self.gender?.rawValue.makeNode() ?? Node.null
        let size = self.size?.rawValue.makeNode() ?? Node.null
        let act = self.activity?.rawValue.makeNode() ?? Node.null
        let train = self.training?.rawValue.makeNode() ?? Node.null
        let vacc = self.vaccination?.rawValue.makeNode() ?? Node.null
        let stat1 = self.animalstatus?.rawValue.makeNode() ?? Node.null
        let stat2 = self.status?.rawValue.makeNode() ?? Node.null
        let nam = self.name.makeNode()
        let shel = String(self.shelterId).makeNode()
        
        let db: DBEntry =
            [AnimalDBKey.id : Node(self.id),
             AnimalDBKey.name : nam,
             AnimalDBKey.shelterId : shel,
             AnimalDBKey.race : race,
             AnimalDBKey.description : desc,
             AnimalDBKey.birthDate : birth,
             AnimalDBKey.admittanceDate : admitt,
             AnimalDBKey.chipId : chip,
             AnimalDBKey.sterilization : ster,
             AnimalDBKey.species : spec,
             AnimalDBKey.gender : gend,
             AnimalDBKey.size : size,
             AnimalDBKey.activity : act,
             AnimalDBKey.training : train,
             AnimalDBKey.vaccination : vacc,
             AnimalDBKey.animalstatus : stat1,
             AnimalDBKey.status : stat2
        ]
        
        return db
    }
}

