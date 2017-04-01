//
//  AnimalBackend.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Foundation
import LoggerAPI

public class AnimalBackend {
    let db: DBLayer
    
    public init(db: DBLayer) {
        self.db = db
    }

    public func delete(byId id: Int) throws -> String {
        try db.deleteAnimal(byId: id)
        return ""
    }
    
    /**
     Modyfikacja obiektu
     
     - Parameter dictionary
     */
    public func edit(withDictionary dictionary: JSONDictionary, withShelterId shelterId: Int) throws -> Int {
        guard let animal = Animal(withJSON: dictionary, withShelterId: shelterId) else {
            throw ResultCode.AnimalBackendBadParameters
        }
        let id = try db.editAnimal(values: animal.dbRepresentation())
        return id
    }

    /**
     Dodawanie obiektu do bazy
 
    - Parameter dictionary
    */
    public func add(withDictionary dictionary: JSONDictionary, withShelterId shelterId: Int) throws -> Int {
        guard let animal = Animal(withJSON: dictionary, withShelterId: shelterId) else {
            throw ResultCode.AnimalBackendBadParameters
        }
        let id = try db.addIntoAnimal(values: animal.dbRepresentation())
        return id
    }
    
    /**
     Pobieranie wszystkich obiektów
     
     */
    public func getall(shelterid: Int?, params: [String: String]) throws -> JSONDictionary {
        var dbresult: [DBEntry]?

        let animalQuery = AnimalQueryBuilder(params: params, shelterId: shelterid).build()
        dbresult = try animalQuery.flatMap(db.execute)

        guard let dbResult = dbresult, !dbResult.isEmpty else {
            return [:]
        }

        let photo = PhotoBackend(db: db)
        var animals: [JSONDictionary] = []
        let shelter = ShelterBackend(db: db)
//        // TODO: metody pobierania danych z bazy być może powinny pracować na innym wątku,
//        // TODO: wymaga to zastosowania zabezpieczeń, choćby DispatchGroup

        for entry in dbResult {
            guard var animal = Animal(dictionary: entry) else {
                throw ResultCode.AnimalBackendBadParameters
            }
            let photoresult = try photo.get(byId: animal.id)
            let shelterDictionary = try shelter.get(byId: animal.shelterId)
            let shelterName = Shelter(withJSON: shelterDictionary)?.name
            animal.shelterName = shelterName
            var outputanimal = animal.dictionaryRepresentation()
            outputanimal[AnimalJSON.photos] = photoresult[AnimalJSON.photos]
            animals.append(outputanimal)
        }
        let metajson: JSONDictionary = [AnimalJSON.data : animals, AnimalJSON.total : "1"]
        return metajson
    }

    /**
    Pobieranie dokładnie jednego obiektu o zadanym id

    - Parameter id
    */
    public func get(byId id: Int) throws -> JSONDictionary {
        let dbresult = try db.fetch(byId: id, table: Config.animaltable, idname: AnimalDBKey.id)
        if dbresult.count == 0 {
            throw ResultCode.AnimalBackendNoData
        }
        if dbresult.count > 1 {
            throw ResultCode.AnimalBackendTooManyEntries
        }
        guard var animal = Animal(dictionary: dbresult.first!) else {
            throw ResultCode.AnimalBackendBadParameters
        }
        let photo = PhotoBackend(db: db)
        let photoresult = try photo.get(byId: animal.id)
        let shelter = ShelterBackend(db: db)
        let shelterDictionary = try shelter.get(byId: animal.shelterId)
        let shelterName = Shelter(withJSON: shelterDictionary)?.name
        animal.shelterName = shelterName

        var outputjson: JSONDictionary = animal.dictionaryRepresentation()
        outputjson[AnimalJSON.photos] = photoresult[AnimalJSON.photos]
        return outputjson
    }
    
    /**
    Pobieranie wielu obiektów z uwzględnieniem stronicowania oraz dodatkowych parametrów użytkownika
 
    - Parameter page
    - Parameter size
    - Parameter params
    */
    public func get(byPage page: Int, size: Int, shelterid: Int?, withParameters params: ParamDictionary) throws -> JSONDictionary {
        if !params.isEmpty {
            // TODO
            // w zapytaniu są dodatkowe parametry

        }
        var dbresult: [DBEntry]
        
        if let shelterid = shelterid {
            dbresult = try db.fetch(byPage: page, size: size, shelterid: shelterid, table: Config.animaltable)
        } else {
            dbresult = try db.fetchActiveAnimals(byPage: page, size: size, table: Config.animaltable)
        }
        
        if dbresult.count == 0 {
            throw ResultCode.AnimalBackendNoData
        }
        let photo = PhotoBackend(db: db)
        var animals: [JSONDictionary] = []
        var totalPages: Int = 0

        // TODO: metody pobierania danych z bazy być może powinny pracować na innym wątku,
        // TODO: wymaga to zastosowania zabezpieczeń, choćby DispatchGroup
        for entry in dbresult {
            guard let animal = Animal(dictionary: entry) else {
                throw ResultCode.AnimalBackendBadParameters
            }
            let photoresult = try photo.get(byId: animal.id)
            var outputanimal = animal.dictionaryRepresentation()
            outputanimal[AnimalJSON.photos] = photoresult[AnimalJSON.photos]
            animals.append(outputanimal)
        }
        if let count = dbresult.first?["count"], let intcount = count.int {
            totalPages = (intcount/size)
            if intcount % size > 0 {
                totalPages += 1
            }
        }
        let metajson: JSONDictionary = [AnimalJSON.data : animals, AnimalJSON.total : totalPages]
        return metajson
    }
    
    /**
     Pobieranie wielu obiektów na podstawie tablicy id
     
     - Parameter ids
     */
    public func get(byIds ids: [Int]) throws -> JSONDictionary {
        let dbresult = try db.fetch(byIds: ids, table: Config.animaltable, idname: AnimalJSON.id)
        if dbresult.count == 0 {
            throw ResultCode.AnimalBackendNoData
        }
        let photo = PhotoBackend(db: db)
        var animals: [JSONDictionary] = []
        
        // TODO: metody pobierania danych z bazy być może powinny pracować na innym wątku,
        // TODO: wymaga to zastosowania zabezpieczeń, choćby DispatchGroup
        for entry in dbresult {
            guard let animal = Animal(dictionary: entry) else {
                throw ResultCode.AnimalBackendBadParameters
            }
            let photoresult = try photo.get(byId: animal.id)
            var outputanimal = animal.dictionaryRepresentation()
            outputanimal[AnimalJSON.photos] = photoresult[AnimalJSON.photos]
            animals.append(outputanimal)
        }
        
        let metajson: JSONDictionary = [AnimalJSON.data : animals, AnimalJSON.total : 1]
        return metajson
    }

    public func deleteAll(byId id: Int) throws -> [String] {
        return []
    }
    
}
