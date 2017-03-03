//
//  PhotoBackend.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import Foundation

public class PhotoBackend_oldapi: Model {
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
            guard let photo = Photo_oldapi(dictionary: entry) else {
                throw ResultCode.PhotoBackendBadParameters
            }
            var photodictionary = photo.dictionaryRepresentation()
            if let filename = photodictionary[PhotoJSON.url] as? String {
                photodictionary[PhotoJSON.url] = (db.config.oldapiUrl + filename) as Any
            }
            photos.append(photodictionary)
        }
        return [AnimalJSON.photos : photos]
    }
    
    public func get(byPage page: Int, size: Int, shelterid: Int?, withParameters params: ParamDictionary) throws -> JSONDictionary {
        return [:]
    }

    public func getall(shelterid: Int?) throws -> JSONDictionary {
        return [:]
    }
    
    public func add(withDictionary dictionary: JSONDictionary) throws -> Int {
        return 0
    }
    
    public func edit(withDictionary dictionary: JSONDictionary) throws -> Int {
        return 0
    }
    
    public func get(byIds ids: [Int]) throws -> JSONDictionary {
        return [:]
    }
}

