//
//  DBLayer.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 22.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import PostgreSQL
import LoggerAPI
import SwiftyJSON

public class DBLayer {
    let config: DBConfig
    let db: Database
    
    public init(config: DBConfig) {
        self.config = config
        self.db = PostgreSQL.Database(dbname: config.dbname, user: config.user, password: config.password)
    }
    
    /**
     Modyfikacja zdjęcia profilowego
     
     - Parameter id
     - Parameter flag
     */
    public func changeProfilPhotoFlag(byId id: Int, flag: Bool) throws {
        let cmd = "UPDATE \(Config.phototable) SET \(PhotoDBKey.profil) = $1 WHERE id = $2"
        try db.execute(cmd, [flag.makeNode(), id.makeNode()])
    }
    
    /**
     Sprawdzenie danych logowania
     
     - Parameter email
     - Parameter password
     - Result shelterId
     */
    public func checkLogin(email: String, password: String) throws -> String {
        let cmd = "select \(SecUserDBKey.shelterid) from sec_user where email = $1 and sha_password = digest($2, $3)"
        let result = try db.execute(cmd, [email.makeNode(), password.makeNode(), "sha256".makeNode()])
        
        if result.isEmpty {
            throw ResultCode.DBLayerUnknownUser
        }
        
        guard let id = result.first?[SecUserDBKey.shelterid]?.string else {
            throw ResultCode.DBLayerBadParameters
        }
        
        return id
    }
    
    /**
     Usunięcie wszystkich zdjęć dla wybranego zwierzaka
     
     - Parameter id: id zwierzaka
     */
    public func deleteAllPhotos(byAnimalId id: Int) throws -> [String] {
        let cmd = "DELETE FROM \(Config.phototable) WHERE \(PhotoDBKey.animalid) = $1 RETURNING \(PhotoDBKey.filename)"
        let result = try db.execute(cmd, [id.makeNode()])
        
        if result.isEmpty {
            throw ResultCode.DBLayerBadParameters
        }
        
        var output: [String] = []
        for item in result {
            if let filename = item[PhotoDBKey.filename]?.string {
                output.append(filename)
            }
        }
        return output
    }
    
    /**
     Usunięcie zwierzaka
     
     - Parameter id: id zwierzaka
     */
    
    public func deleteAnimal(byId id: Int) throws {
        let cmd = "DELETE FROM \(Config.animaltable) WHERE \(AnimalDBKey.id) = $1"
        try db.execute(cmd, [id.makeNode()])
    }
    
    /**
     Usunięcie obiektu Photo z tablicy
     
     - Parameter id: id obiektu
     */
    public func deletePhoto(byId id: Int) throws -> String {
        let cmd = "DELETE FROM \(Config.phototable) WHERE \(PhotoDBKey.id) = $1 RETURNING \(PhotoDBKey.filename)"
        let result = try db.execute(cmd, [id.makeNode()])
        
        guard let filename = result.first?[PhotoDBKey.filename]?.string else {
            throw ResultCode.DBLayerBadParameters
        }
        return filename
    }
    
    /**
     Metoda dodaje obiekt do tablicy Photo
     
     - Parameter values: [String : Node]
     */
    public func addIntoPhoto(values: DBEntry) throws -> Int {
        let d = values.map { (k,v) in return (k,v) }
        
        let values1 = "(\(d[0].0), \(d[1].0), \(d[2].0), \(d[3].0))"
        let cmd = "INSERT INTO \(Config.phototable) \(values1) VALUES ($1, $2, $3, $4) RETURNING id"
        let result = try db.execute(cmd, [d[0].1, d[1].1, d[2].1, d[3].1])
        
        guard let id = result.first?["id"]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        return id
    }
    
    /**
     Metoda modyfikuje obiekt w tablicy Animal
     
     - Parameter values: [String : Node]
     */
    public func editAnimal(values: DBEntry) throws -> Int {
        if values.count != 17 {
            throw ResultCode.DBLayerBadParameters
        }
        
        guard let id = values[AnimalDBKey.id]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        
        let d = values.map { (k,v) in
            return (k,v)
            }.filter{$0.0 != AnimalDBKey.id}
        
        let cmd = "UPDATE \(Config.animaltable) SET \(d[0].0)=$1, \(d[1].0)=$2, \(d[2].0)=$3, \(d[3].0)=$4, \(d[4].0)=$5, \(d[5].0)=$6, \(d[6].0)=$7, \(d[7].0)=$8, \(d[8].0)=$9, \(d[9].0)=$10, \(d[10].0)=$11, \(d[11].0)=$12, \(d[12].0)=$13, \(d[13].0)=$14, \(d[14].0)=$15, \(d[15].0)=$16 WHERE id=\(id)  RETURNING id"
        let result = try db.execute(cmd, [ d[0].1, d[1].1, d[2].1, d[3].1, d[4].1, d[5].1, d[6].1, d[7].1, d[8].1, d[9].1, d[10].1, d[11].1, d[12].1, d[13].1, d[14].1, d[15].1] )
        
        guard let returnid = result.first?["id"]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        
        return returnid
    }
    
    /**
     Metoda dodaje obiekt w tablicy Animal
     
     - Parameter values: [String : Node]
     */
    public func addIntoAnimal(values: DBEntry) throws -> Int {
        if values.count != 17 {
            throw ResultCode.DBLayerBadParameters
        }
        // filter usuwa 'id', który jest zbędny podczas tworzenia nowego obiektu
        let d = values.map { (k,v) in
            return (k,v)
            }.filter{$0.0 != AnimalDBKey.id}
        
        let values1 = "(\(d[0].0), \(d[1].0), \(d[2].0), \(d[3].0), \(d[4].0), \(d[5].0), \(d[6].0), \(d[7].0), \(d[8].0), \(d[9].0), \(d[10].0), \(d[11].0), \(d[12].0), \(d[13].0), \(d[14].0), \(d[15].0))"
        
        let cmd = "INSERT INTO \(Config.animaltable) \(values1) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16) RETURNING id"
        
        let result = try db.execute(cmd, [ d[0].1, d[1].1, d[2].1, d[3].1, d[4].1, d[5].1, d[6].1, d[7].1, d[8].1, d[9].1, d[10].1, d[11].1, d[12].1, d[13].1, d[14].1, d[15].1] )
        
        guard let id = result.first?["id"]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        
        return id
    }
    
    /**
     Metoda zwraca obiekt o zadanym id z zadanej tabeli
     
     - Parameter id
     - Parameter table
     - Parameter idname
     */
    public func fetch(byId id: Int, table: String, idname: String) throws -> [DBEntry] {
        let sqlcmd = "SELECT * FROM \(table) WHERE \(idname) = \(id)"
        return try db.execute(sqlcmd)
    }
    
    /**
     Metoda zwraca tablicę obiektów na podstawie przesłanej tablicy id
     
     - Parameter ids
     - Parameter table
     - Parameter idname
     */
    public func fetch(byIds ids: [Int], table: String, idname: String) throws -> [DBEntry] {
        var tmp: String = ""
        
        for i in ids {
            tmp.append("\(idname) = \(i) OR ")
        }
        tmp.append("FALSE")
        let sqlcmd = "SELECT * FROM \(table) WHERE \(tmp)"
        return try db.execute(sqlcmd)
    }
    
    
    
    /**
     Metoda zwraca obiekty z uwzględnieniem stronicowania oraz id schroniska
     Wykorzystywana przez panel
     
     - Parameter page
     - Parameter size
     - Parameter shelterid
     - Parameter table
     */
    public func fetch(byPage page: Int, size: Int, shelterid: Int, table: String) throws -> [DBEntry] {
        if page < 0 || size < 1 {
            throw ResultCode.DBLayerBadPageOrSize
        }
        let offset = page * size
        let sqlcmd = "select *, (select count(*) from \(table) where \(AnimalDBKey.shelterId)=\(shelterid)) as count from \(table) where \(AnimalDBKey.shelterId)=\(shelterid) offset \(offset) limit \(size)"
        return try db.execute(sqlcmd)
    }
    
    /**
     Metoda zwraca wszystkie obiekty z uwzględnieniem id schroniska
     Wykorzystywana przez panel
     */
    public func fetchAll(shelterid: Int) throws -> [DBEntry] {
        let sqlcmd = "SELECT * FROM \(Config.animaltable) WHERE \(AnimalDBKey.shelterId) = \(shelterid)"
        return try db.execute(sqlcmd)
    }
    
    /**
     Metoda specyficzna dla obiektów w tablicy ANIMAL, zwraca tylko aktywne zwierzaki
     Wykorzystywana przez klienta mobilnego
     
     - Parameter page
     - Parameter size
     - Parameter table
     */
    public func fetchActiveAnimals(byPage page: Int, size: Int, table: String) throws -> [DBEntry] {
        if page < 0 || size < 1 {
            throw ResultCode.DBLayerBadPageOrSize
        }
        let offset = page * size
        
        let sqlcmd = "select *, (select count(*) from \(table)) as count from \(table) offset \(offset) limit \(size)"
        return try db.execute(sqlcmd)
    }
    
    public func fetch(fromTable table: String) throws -> [DBEntry] {
        let sqlCommand = "select * from \(table)"
        return try db.execute(sqlCommand)
    }
    
    /**
     Metoda zwraca wszystkie obiekty z podanej tabeli
     Wykorzystywana przez klienta mobilnego
     
     - Parameter table
     */
    public func fetchAllActiveAnimals(table: String) throws -> [DBEntry] {
        
        let sqlcmd = "SELECT * FROM \(table)"
        return try db.execute(sqlcmd)
    }
    
    public func editShelter(values: DBEntry) throws -> Int {
        if values.count != 13 {
            throw ResultCode.DBLayerBadParameters
        }
        
        guard let id = values[ShelterDBKey.id]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        
        let d = values.map { (k,v) in return (k,v) }.filter{ $0.0 != ShelterDBKey.id }
        
        let cmd = "UPDATE \(Config.shelterTable) SET \(d[0].0)=$1, \(d[1].0)=$2, \(d[2].0)=$3, \(d[3].0)=$4, \(d[4].0)=$5, \(d[5].0)=$6, \(d[6].0)=$7, \(d[7].0)=$8, \(d[8].0)=$9, \(d[9].0)=$10, \(d[10].0)=$11, \(d[11].0)=$12  WHERE id=\(id) RETURNING ID"
        
        let result = try db.execute(cmd, [d[0].1, d[1].1, d[2].1, d[3].1, d[4].1, d[5].1, d[6].1, d[7].1, d[8].1, d[9].1, d[10].1, d[11].1] )
        
        guard let updatedId = result.first?["id"]?.int else {
            throw ResultCode.DBLayerBadParameters
        }
        
        return updatedId
    }
    
    func updatePassword(forUser secUser: SecUser, withShelterId shelterId: Int) throws -> Int {
        
        //check if the old password is correct
        let passwordCheckCmd = "select email from sec_user where shelter_id = $1 and sha_password = digest($2, $3)"
        guard let oldPasswordNode = secUser.oldPassword?.makeNode() else {
            throw SecUserError.badDbParams
        }
        
        let passwordCheckResult = try db.execute(passwordCheckCmd, [shelterId.makeNode(), oldPasswordNode, "sha256".makeNode()])
        
        guard !passwordCheckResult.isEmpty else {
            throw SecUserError.wrongOldPassword(JSON([SecUser.oldPasswordKey: "Incorrect"]))
        }
        
        //if all good update the password
        let passwordChangeCmd = "UPDATE \(Config.secUserTable) SET sha_password = digest($1, $2) where shelter_id = \(shelterId) RETURNING SHELTER_ID"
        
        var passwordChangeResult:[[String: Node]]?
        if let newPasswordNode = secUser.newPassword?.makeNode() {
            passwordChangeResult = try db.execute(passwordChangeCmd, [newPasswordNode, "sha256".makeNode()])
        }
        
        guard !passwordCheckResult.isEmpty, let updatedId = passwordChangeResult?.first?["shelter_id"]?.int else {
            throw SecUserError.badDbParams
        }
        
        return updatedId
    }
    
    func update(areTermsOfUseAccepted accepted: Bool, forShelterId shelterId: Int) throws -> Int {
        let termsUpdateCmd = "UPDATE \(Config.secUserTable) SET are_terms_of_use_accepted = $1 WHERE shelter_id = $2 RETURNING SHELTER_ID"
        
        let termsUpdateResult = try db.execute(termsUpdateCmd, [accepted.makeNode(), shelterId.makeNode()])
        
        guard !termsUpdateResult.isEmpty, let updatedId = termsUpdateResult.first?["shelter_id"]?.int else {
            throw SecUserError.badDbParams
        }
        
        return updatedId
    }
    
    func areTermsOfUseAccepted(forShelterId shelterId: Int) throws -> Bool {
        
        let areTermsAcceptedCmd = "SELECT are_terms_of_use_accepted from \(Config.secUserTable) where shelter_id = $1"
        
        let areTermsAcceptedResult = try db.execute(areTermsAcceptedCmd, [shelterId.makeNode()])
        
        guard !areTermsAcceptedResult.isEmpty, let accepted = areTermsAcceptedResult.first?["are_terms_of_use_accepted"]?.bool else {
            throw SecUserError.badDbParams
        }
        
        return accepted
    }
    
    func execute(_ query: String) throws -> [DBEntry]? {
        return try db.execute(query)
    }
    
    
}
