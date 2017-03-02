//
//  Photo.swift
//  Na4lapyAPI
//
//  Created by scoot on 30.12.2016.
//
//

import PostgreSQL

struct Photo {
    private let id: Int
    private let animalid: Int
    private let filename: String
    private let author: String?
    private let profil: Bool
    
    init?(dictionary: DBEntry) {
        guard
            let animalid = dictionary[PhotoDBKey.animalid]?.int,
            let id = dictionary[PhotoDBKey.id]?.int,
            let filename = dictionary[PhotoDBKey.filename]?.string
        else {
            return nil
        }
        self.id = id
        self.animalid = animalid
        self.filename = filename
        self.author = dictionary[PhotoDBKey.author]?.string
        self.profil = dictionary[PhotoDBKey.profil]?.bool ?? false
    }

    init?(withJson json: JSONDictionary) {
        guard
            let animalid = json[PhotoJSON.animalid] as? Int,
            let filename = json[PhotoJSON.filename] as? String
            else {
                return nil
        }
        self.id = 0
        self.animalid = animalid
        self.filename = filename
        self.author = json[PhotoJSON.author] as? String
        self.profil = json[PhotoJSON.profil] as? String == "true" ? true : false
    }
    
    func dictionaryRepresentation() -> JSONDictionary {
        let author = self.author ?? ""
        let dict: JSONDictionary = [
            PhotoJSON.id : self.id,
            PhotoJSON.filename : self.filename,
            PhotoJSON.author : author,
            PhotoJSON.profil : self.profil
        ]
        return dict
    }
    
    func dbRepresentation() -> DBEntry {
        let filename = self.filename.makeNode()
        let animalid = String(self.animalid).makeNode()
        let author = self.author?.makeNode() ?? Node.null
        let profil = self.profil.makeNode()
        
        let entry: DBEntry = [PhotoDBKey.animalid : animalid,
                              PhotoDBKey.filename : filename,
                              PhotoDBKey.author : author,
                              PhotoDBKey.profil : profil
        ]
        
        return entry
    }
}
