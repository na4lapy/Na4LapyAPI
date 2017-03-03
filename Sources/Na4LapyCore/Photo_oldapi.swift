//
//  Photo.swift
//  Na4lapyAPI
//
//  Created by scoot on 30.12.2016.
//
//

struct Photo_oldapi {
    private let id: Int
    private let animalid: Int
    private let filename: String
    private let author: String?
    
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
    }
    
    func dictionaryRepresentation() -> JSONDictionary {
        
        let author = self.author ?? ""
        let dict: JSONDictionary = [
            PhotoJSON.id : self.id,
            PhotoJSON.url : self.filename,
            PhotoJSON.author : author
        ]
        return dict
    }
}
