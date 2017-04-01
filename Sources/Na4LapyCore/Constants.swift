//
//  Constants.swift
//  Na4lapyAPI
//
//  Created by Andrzej Butkiewicz on 23.12.2016.
//  Copyright © 2016 Stowarzyszenie Na4Łapy. All rights reserved.
//

import PostgreSQL
import Foundation

//
// DB Parameters
//
public struct DBDefault {
    public static let dbname = "na4lapyprod"
    public static let user = "na4lapy"
    public static let password = "na4pass"
    public static let host = "127.0.0.1"
}

public struct DBConfig {
    public var dbname: String
    public var user: String
    public var password: String
    public var host: String
    public var oldapiUrl: String = ""
    
    public init() {
        self.dbname = DBDefault.dbname
        self.user = DBDefault.user
        self.password = DBDefault.password
        self.host = DBDefault.host
    }
}

//
// Aliasy
//
public typealias JSONDictionary = [String : Any]
public typealias ParamDictionary = [String : String]
public typealias DBEntry = [String : Node]

//
// Błędy
//
public enum ResultCode: Error {
    case DBLayerBadPageOrSize
    case DBLayerBadParameters
    case DBLayerUnknownUser
    case AnimalBackendNoData
    case AnimalBackendTooManyEntries
    case AnimalBackendBadParameters
    case PhotoBackendNoData
    case PhotoBackendBadParameters
    case ShelterBackendNoData
    case ShelterBackendTooManyEntries
    case ShelterBackendBadParameters
    case FileUploadBadParameters
    case AuthorizationError
}

//
// Kody błędów
//
extension ResultCode: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .DBLayerBadPageOrSize:
            return "Numer strony musi być >= 0, a size > 0"
        case .DBLayerUnknownUser:
            return "Nieprawidłowy login lub hasło"
        case .AnimalBackendBadParameters:
            return "Niepoprawny format obiektu Animal -- brak 'id' lub 'name'"
        case .AnimalBackendTooManyEntries, .ShelterBackendTooManyEntries:
            return "Zwrócono zbyt dużą liczbę rekordów -- powinno być 1."
        case .AnimalBackendNoData, .ShelterBackendNoData:
            return "Brak danych"
        case .PhotoBackendNoData:
            return "Brak zdjęcia"
        case .PhotoBackendBadParameters:
            return "Niepoprawny format obiektu Photo -- brak 'id', 'filename' lub 'animal_id'"
        case .DBLayerBadParameters, .ShelterBackendBadParameters:
            return "Nieprawidłowe parametry"
        case .FileUploadBadParameters:
            return "Niepoprawne parametry podczas uploadu pliku ze zdjęciem"
        case .AuthorizationError:
            return "Brak dostępu"
        }
    }
    
}

//
// Nagłówki dołączane do odpowiedzi
//

struct ResponseHeader {
    static let cacheControl = "Cache-Control"
    static let cacheControlValue = "max-age=7200"
}

// 
// Format daty dla wszystkich zmiennych typu Date
//

struct Config {
    static let dateFormat = "yyyy-MM-dd"
    static let animaltable = "animal"
    static let phototable = "photo"
    static let shelterTable = "shelter"
    static let secUserTable = "sec_user"
    static let oldapiPhotoUrl = "http://api.na4lapy.org/images/"
}

struct SecUserDBKey {
    static let shelterid = "shelter_id"
}

//
// Animal JSON keys
//
struct AnimalJSON {
    static let name = "name"
    static let id = "id"
    static let shelterid = "shelterid"
    static let shelterName = "shelterName"
    static let race = "race"
    static let description = "description"
    static let birthDate = "birthdate"
    static let admittanceDate = "admittancedate"
    static let chipId = "chipid"
    static let sterilization = "sterilization"
    static let species = "species"
    static let gender = "gender"
    static let size = "size"
    static let activity = "activity"
    static let training = "training"
    static let vaccination = "vaccination"
    static let photos = "photos"
    static let url = "url"
    static let author = "author"
    static let animalstatus = "animal_status"
    static let status = "status"
    static let total = "totalPages"
    static let data = "data"
    static let calculatedPreferences = "calculatedPreferences"
}

struct AnimalDBKey {
    static let name = "name"
    static let id = "id"
    static let shelterId = "shelter_id"
    static let race = "race"
    static let description = "description"
    static let birthDate = "birth_date"
    static let admittanceDate = "admittance_date"
    static let chipId = "chip_id"
    static let sterilization = "sterilization"
    static let species = "species"
    static let gender = "gender"
    static let size = "size"
    static let activity = "activity"
    static let training = "training"
    static let vaccination = "vaccination"
    static let photos = "photos"
    static let url = "url"
    static let author = "author"
    static let animalstatus = "animal_status"
    static let status = "status"
    static let total = "total"
    static let data = "data"
    static let calculatedPreferences = "calculatepreferences"
}

struct PhotoDBKey {
    static let id = "id"
    static let url = "url"
    static let animalid = "animal_id"
    static let filename = "file_name"
    static let author = "author"
    static let profil = "profil"
}

struct PhotoJSON {
    static let id = "id"
    static let url = "url"
    static let filename = "fileName"
    static let author = "author"
    static let animalid = "animalId"
    static let profil = "profil"
}

struct ShelterDBKey {
    static let id = "id"
    static let name = "name"
    static let street = "street"
    static let building_number = "building_number"
    static let city = "city"
    static let postal_code = "postal_code"
    static let voivodeship = "voivodeship"
    static let email = "email"
    static let phone_number = "phone_number"
    static let website = "website"
    static let facebook_profile = "facebook_profile"
    static let account_number = "account_number"
    static let adoption_rules = "adoption_rules"
    static let status = "active"

}

struct ShelterJSON {
    static let id = "id"
    static let name = "name"
    static let street = "street"
    static let building_number = "buildingNumber"
    static let city = "city"
    static let postal_code = "postalCode"
    static let voivodeship = "voivodeship"
    static let email = "email"
    static let phone_number = "phoneNumber"
    static let website = "website"
    static let facebook_profile = "facebookProfile"
    static let account_number = "accountNumber"
    static let adoption_rules = "adoptionRules"
    static let status = "active"
}

enum Sterilization: String {
    case sterilized = "STERILIZED"
    case notSterilized = "NOT_STERILIZED"
}

enum Gender: String {
    case male = "MALE"
    case female = "FEMALE"
    case unknown = "UNKNOWN"
    
    func pl() -> String {
        switch self {
        case .male:
            return "Samiec"
        case .female:
            return "Suczka"
        default:
            return "Brak"
        }
    }
}

enum Size: String {
    case small = "SMALL"
    case medium = "MEDIUM"
    case large = "LARGE"
    
    func pl() -> String {
        switch self {
        case .small:
            return "Maly"
        case .medium:
            return "Sredni"
        case .large:
            return "Duzy"
        }
    }
}

enum Activity: String {
    case low = "LOW"
    case high = "HIGH"
    case unknown = "UNKNOWN"
    
    func pl() -> String {
        switch self {
        case .low:
            return "Domator"
        case .high:
            return "Aktywny"
        default:
            return "Brak"
        }
    }
}

enum Training: String {
    case none = "NONE"
    case basic = "BASIC"
    case advanced = "ADVANCED"
    case unknown = "UNKNOWN"
}

enum Vaccination: String {
    case basic = "BASIC"
    case extended = "EXTENDED"
    case none = "NONE"
    case unknown = "UNKNOWN"
}

enum AnimalStatus: String {
    case forAdoption = "FOR_ADOPTION"
    case new = "NEW"
    case adopted = "ADOPTED"
}

enum Status: String {
    case deleted = "DELETED"
    case active = "ACTIVE"
}

enum Species: String {
    case dog = "DOG"
    case cat = "CAT"
    case other = "OTHER"
}

