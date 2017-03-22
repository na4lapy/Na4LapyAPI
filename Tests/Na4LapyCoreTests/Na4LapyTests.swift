//
//  Na4LapyTest.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 03/03/2017.
//
//

import XCTest

import PostgreSQL
import Foundation
@testable import Na4LapyCore

class Na4LapyCoreTests: XCTestCase {

//    func testDatabaseFetch() {
//        let dbconfig = DBConfig()
//        let db = DBLayer(config: dbconfig)
//        do {
//            let result = try db.fetch(byId: 27, table: "animal", idname: "id")
//            if result.count == 1 {
//                XCTFail("Zwrócono nieprawidłową liczbę obiektów (różną od 1)")
//                return
//            }
//            let animal = Animal(dictionary: result.first!)
//            XCTAssertNotNil(animal, "Zwrócony obiekt jest w nieprawidłowym formacie")
//        } catch {
//            XCTFail("Brak komunikacji z bazą danych")
//        }
//    }

    func testAnimalObjectDictionaryRepresentation() {
        let input: DBEntry = [
            AnimalDBKey.name : Node("Vika"),
            AnimalDBKey.id   : Node(10),
            AnimalDBKey.shelterId : Node(100),
            AnimalDBKey.race : Node("Labiszon"),
            AnimalDBKey.description : Node("Wiecznie głodny"),
            AnimalDBKey.sterilization : Node("STERILIZED"),
            AnimalDBKey.gender : Node("FEMALE"),
            AnimalDBKey.size : Node("MEDIUM"),
            AnimalDBKey.activity : Node("HIGH"),
            AnimalDBKey.training : Node("BASIC"),
            AnimalDBKey.vaccination : Node("BASIC"),
            AnimalDBKey.animalstatus : Node("NEW"),
            AnimalDBKey.status : Node("ACTIVE"),
            AnimalDBKey.species : Node("DOG")
        ]

        guard let animal = Animal(dictionary: input) else {
            XCTFail("Obiekt Animal nie został poprawnie zainicjowany")
            return
        }

        let output = animal.dictionaryRepresentation()
        let name = output[AnimalJSON.name] as? String
        let id = output[AnimalJSON.id] as? Int
        let shelter = output[AnimalJSON.shelterid] as? Int
        let race = output[AnimalJSON.race] as? String
        let desc = output[AnimalJSON.description] as? String
        let ster = output[AnimalJSON.sterilization] as? String
        let gender = output[AnimalJSON.gender] as? String
        let size = output[AnimalJSON.size] as? String
        let activ = output[AnimalJSON.activity] as? String
        let train = output[AnimalJSON.training] as? String
        let vacc = output[AnimalJSON.vaccination] as? String
        let stat1 = output[AnimalJSON.animalstatus] as? String
        let stat2 = output[AnimalJSON.status] as? String
        let spec = output[AnimalJSON.species] as? String

        XCTAssertEqual(name, "Vika")
        XCTAssertEqual(id, 10)
        XCTAssertEqual(shelter, 100)
        XCTAssertEqual(race, "Labiszon")
        XCTAssertEqual(desc, "Wiecznie głodny")
        XCTAssertEqual(ster, "STERILIZED")
        XCTAssertEqual(gender, "FEMALE")
        XCTAssertEqual(size, "MEDIUM")
        XCTAssertEqual(activ, "HIGH")
        XCTAssertEqual(train, "BASIC")
        XCTAssertEqual(vacc, "BASIC")
        XCTAssertEqual(stat1, "NEW")
        XCTAssertEqual(stat2, "ACTIVE")
        XCTAssertEqual(spec, "DOG")
    }

    func testDateExtension() {
        let testString = "2016-12-24"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Config.dateFormat
        guard let testDate = dateFormatter.date(from: testString) else {
            XCTFail("Nie udało się utworzyć daty")
            return
        }

        let outputString = testDate.toString()
        XCTAssertEqual(testString, outputString, "Daty nie są zgodne")
    }


    static var allTests : [(String, (Na4LapyCoreTests) -> () throws -> Void)] {
        return [
            ("testAnimalObjectDictionaryRepresentation", testAnimalObjectDictionaryRepresentation),
            ("testDateExtension", testDateExtension)
        ]
    }
}
