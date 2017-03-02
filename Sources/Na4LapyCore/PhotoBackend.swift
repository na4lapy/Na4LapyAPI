//
//  PhotoBackend.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Foundation

public class PhotoBackend: Model {
    let db: DBLayer
    
    public init(db: DBLayer) {
        self.db = db
    }

    /**
     Usunięcie wszystkich zdjęć dla id zwierzaka
     
     - Parameter id
     */
    public func deleteAll(byId id: Int) throws -> [String] {
        return try db.deleteAllPhotos(byAnimalId: id)
    }

    /**
     Usunięcie zdjęcia o zadanym id
     
     - Parameter id
     */
    public func delete(byId id: Int) throws -> String {
        return try db.deletePhoto(byId: id)
    }
    
    /**
     Pobranie zdjęć dla obiektu o zadanym id
     
     - Parameter id
     */
    public func get(byId id: Int) throws -> JSONDictionary {
        let dbresult = try db.fetch(byId: id, table: Config.phototable, idname: PhotoDBKey.animalid)
        if dbresult.count == 0 {
           // throw ResultCode.PhotoBackendNoData
        }
        var photos: [JSONDictionary] = []
        for entry in dbresult {
            guard let photo = Photo(dictionary: entry) else {
                throw ResultCode.PhotoBackendBadParameters
            }
            photos.append(photo.dictionaryRepresentation())
        }
        return [AnimalJSON.photos : photos]
    }
    
    public func add(withDictionary dictionary: JSONDictionary) throws -> Int {
        guard let photo = Photo(withJson: dictionary) else {
            throw ResultCode.PhotoBackendNoData
        }
        
        let id = try db.addIntoPhoto(values: photo.dbRepresentation())
        return id
    }
    
    public func edit(withDictionary dictionary: JSONDictionary) throws -> Int {
        guard let id = dictionary[PhotoJSON.id] as? Int,
            let profilFlag = dictionary[PhotoJSON.profil] as? Bool else {
                throw ResultCode.PhotoBackendBadParameters
        }
        
        try db.changeProfilPhotoFlag(byId: id, flag: profilFlag)
        return id
    }

    public func get(byPage page: Int, size: Int, shelterid: Int?, withParameters params: ParamDictionary) throws -> JSONDictionary {
        return [:]
    }
    
    public func getall(shelterid: Int?) throws -> JSONDictionary {
        return [:]
    }
    
    public func get(byIds ids: [Int]) throws -> JSONDictionary {
        return [:]
    }
}
