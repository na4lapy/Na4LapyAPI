//
//  Model.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 24.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

public protocol Model {
    func get(byId id: Int) throws -> JSONDictionary
    func get(byPage page: Int, size: Int, shelterid: Int?, withParameters: ParamDictionary) throws -> JSONDictionary
    func get(byIds ids: [Int]) throws -> JSONDictionary
    func getall(shelterid: Int?) throws -> JSONDictionary
    func add(withDictionary dictionary: JSONDictionary) throws -> Int
    func edit(withDictionary dictionary: JSONDictionary) throws -> Int
    func delete(byId id: Int) throws -> String
    func deleteAll(byId id: Int) throws -> [String]
}
