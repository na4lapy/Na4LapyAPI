//
//  AnimalRequestBuilder.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 19/03/2017.
//
//

import Foundation

typealias RequestParams = [String: String]

class AnimalQueryBuilder {

    var shelterId: Int?
    var calculatePrefs:Bool? = false
    var animalType: Species?
    var animalSize: Size?
    var gender: Gender?
    var activity: Activity?
    var sterilization: Sterilization?
    var training: Training?
    var vaccination: Vaccination?
    var animalStatus: AnimalStatus?
    var minAge: Int?
    var maxAge: Int?
    var name: String?
    var size: Int?
    var page: Int?

    init(params: RequestParams, shelterId: Int?) {
        self.parse(params)
        self.shelterId = shelterId
    }

//
    func build() -> String? {
        var dbCommand = "select * from \(Config.animaltable)"

        //we are calculating preferences
        if let calculatePrefs = calculatePrefs, calculatePrefs  {
            dbCommand += " \(calculatePrefsCommand())"
            dbCommand += shelterId.map {id in return " where \(AnimalDBKey.shelterId) = \(id)"} ?? ""
            dbCommand += " order by calculatepreferences desc"
        } else {
            //normal filtering
            var filterQuery = [String?]()
            filterQuery.append(shelterId.map {" \(AnimalDBKey.shelterId) = \($0)"})
            filterQuery.append(gender.map { " \(AnimalDBKey.gender) = '\($0.rawValue)'" })
            filterQuery.append(activity.map {" \(AnimalDBKey.activity) = '\($0.rawValue)'" })
            filterQuery.append(training.map {" \(AnimalDBKey.training) = '\($0.rawValue)'"})
            filterQuery.append(vaccination.map {" \(AnimalDBKey.vaccination) = '\($0.rawValue)'"})
            filterQuery.append(name.map {" \(AnimalDBKey.name) ilike '\($0)%'"})
            filterQuery.append(animalSize.map {" \(AnimalDBKey.size) = '\($0.rawValue)'"})
            filterQuery.append(sterilization.map {" \(AnimalDBKey.sterilization) = '\($0.rawValue)')"})
            filterQuery.append(animalStatus.map {" \(AnimalDBKey.animalstatus) = '\($0.rawValue)'"} )

            let notNilFiletrs = filterQuery.flatMap({ $0 })
            if !notNilFiletrs.isEmpty {
                dbCommand += " where"
                dbCommand += notNilFiletrs.joined(separator: " and")
            }
            
        }

        //TODO: Throw when size and page makes no sense
        if let size = size {
            dbCommand += " limit \(size)"
        }

        if let page = page, let size = size {
            let offset = size * page
            dbCommand += " offset \(offset)"
        }

        dbCommand += ";"
        return dbCommand
    }

    private func calculatePrefsCommand()  -> String {
        var age = (minAge: 0, maxAge: 0)

        if let minAge = self.minAge, let maxAge = self.maxAge {
            age.minAge = minAge
            age.maxAge = maxAge
        }

        return "as animal, calculatepreferences(animal, " +
        "'\(self.animalType == .dog ? 1 : 0)'," +
        "'\(self.animalType == .cat ? 1 : 0)'," +
        "'\(self.animalType == .other ? 1 : 0)'," +
        "'\(self.gender == .male ? 1 : 0)'," +
        "'\(self.gender == .female ? 1 : 0)'," +
        "'\(self.animalSize == .small ? 1 : 0)'," +
        "'\(self.animalSize == .medium ? 1 : 0)'," +
        "'\(self.animalSize == .large ? 1 : 0)'," +
        "'\(self.activity == .high ? 1 : 0)'," +
        "'\(self.activity == .low ? 1 : 0)'," +
        "\(age.minAge),\(age.maxAge))"
    }

    private func parse( _ params: RequestParams) {
        self.animalSize = params["animalSize"].flatMap( {Size(rawValue: $0.uppercased() )})
        self.gender = params["gender"].flatMap( {Gender(rawValue: $0.uppercased() )})
        self.name = params["name"]
        self.activity = params["activity"].flatMap( {Activity(rawValue: $0.uppercased() )})
        self.animalType = params["species"].flatMap( {Species(rawValue: $0.uppercased() )})
        self.shelterId = params["shelterId"].flatMap({Int($0)})
        self.sterilization = params["sterilization"].flatMap( {Sterilization(rawValue: $0.uppercased()) } )
        self.training = params["training"].flatMap( {Training(rawValue: $0.uppercased() )} )
        self.animalStatus = params["animalStatus"].flatMap( {AnimalStatus(rawValue: $0.uppercased() )} )
        self.size = params["size"].flatMap({Int($0)})
        self.page = params["page"].flatMap({Int($0)})
        if let calculatePrefsString = params["calculatePrefs"] {
            self.calculatePrefs = calculatePrefsString.toBool()
        }

    }



}

