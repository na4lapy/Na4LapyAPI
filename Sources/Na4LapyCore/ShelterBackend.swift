//
//  ShelterBackend.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 22/02/2017.
//
//

import Foundation

public class ShelterBackend {
    let db: DBLayer

    public init(db: DBLayer) {
        self.db = db
    }

    public func get(byId id: Int) throws -> JSONDictionary {
        let dbresult = try db.fetch(byId: id, table: Config.shelterTable, idname: ShelterDBKey.id)

        if dbresult.count == 0 {
            throw ResultCode.ShelterBackendNoData
        }

        if dbresult.count > 1 {
            throw ResultCode.ShelterBackendTooManyEntries
        }

        guard let shelter = Shelter(dictionary: dbresult.first!) else {
            throw ResultCode.ShelterBackendBadParameters
        }

        return shelter.dictionaryRepresentation()
    }
    
    func getShelter(byId id: Int) throws -> Shelter? {
        let dbEntry = try get(byId: id)
        return Shelter(withJSON: dbEntry)
    }

    public func edit(withDictionary dictionary: JSONDictionary) throws -> Int {
        guard let shelter = Shelter(withJSON: dictionary) else {
            throw ResultCode.ShelterBackendBadParameters
        }
        let id = try db.editShelter(values: shelter.dbRepresentation())
        return id
    }

    public func get() throws -> [JSONDictionary] {
        let dbresult = try db.fetch(fromTable: Config.shelterTable)

        if dbresult.isEmpty {
            throw ResultCode.ShelterBackendNoData
        }

        let shelters = dbresult.flatMap({ Shelter.init(dictionary: $0) })

        if shelters.isEmpty {
            throw ResultCode.ShelterBackendNoData
        }

        return shelters.map { $0.dictionaryRepresentation() }

    }

}
