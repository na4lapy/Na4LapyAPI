//
//  AnimalPreferenceTests.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 19/03/2017.
//
//

import Foundation

import XCTest

import Foundation
import SwiftyJSON
import LoggerAPI

@testable import Na4LapyCore

class AnimalQueryBuilderTests: XCTestCase {

    var sut: AnimalQueryBuilder!
    override func setUp() {
        super.setUp()
        sut = AnimalQueryBuilder(params: [:], shelterId: 1)
    }

    func testBuilderOptionallyTakesShelterId() {
        sut.shelterId = 1
        XCTAssertEqual(sut.shelterId, 1)
    }

    func testBuilderOptionallyTakesCalculatePrefsParams() {
        sut.calculatePrefs = true
        XCTAssertEqual(sut.calculatePrefs, true)
    }

    func testBuilderOptionallyTakesAnimalTypeParam(){
        sut.animalType = Species.dog
        XCTAssertEqual(sut.animalType, Species.dog)
    }

    func testBuilderOptionallyTakesAnimalSizeParam() {
        sut.animalSize = Size.small
        XCTAssertEqual(sut.animalSize, Size.small)
    }

    func testBuilderOptionallyTakesGenderParam(){
        sut.gender = Gender.female
        XCTAssertEqual(sut.gender, Gender.female)
    }

    func testBuilderOptionallyTakesActivityParam(){
        sut.activity = Activity.high
        XCTAssertEqual(sut.activity, Activity.high)
    }

    func testBuilderOptionallyTakesSterilizationParam() {
        sut.sterilization = Sterilization.notSterilized
        XCTAssertEqual(sut.sterilization, Sterilization.notSterilized)

    }

    func testBuilderOptionallyTakesTrainingParam() {
        sut.training = Training.advanced
        XCTAssertEqual(sut.training, Training.advanced)
    }

    func testBuilderOptionallyTakesVaccinationParam() {
        sut.vaccination = Vaccination.basic
        XCTAssertEqual(sut.vaccination, Vaccination.basic)
    }

    func testBuilderOptionallyTakesAnimalStatusParam() {
        sut.animalStatus = AnimalStatus.forAdoption
        XCTAssertEqual(sut.animalStatus, AnimalStatus.forAdoption)
    }

    func testBuilderOptionallyTakesNameParam(){
        sut.name = "Burek"
        XCTAssertEqual(sut.name, "Burek")
    }

    func testBuilderOptionallyTakesSizeParam() {
        sut.size = 10
        XCTAssertEqual(sut.size, 10)
    }

    func testBuilderOptionallyTakesPageParam() {
        sut.page = 1
        XCTAssertEqual(sut.page, 1)
    }

    func testBuilderOptionallyTakesMinAgeParam() {
        sut.minAge = 5
        XCTAssertEqual(sut.minAge, 5)
    }

    func testBuilderOptionallyTakesMaxAgeParam() {
        sut.maxAge = 10
        XCTAssertEqual(sut.maxAge, 10)
    }

    func testShouldReturnDefaultQueryWithNoParams() {

        let expectedCommand = "select * from \(Config.animaltable) where shelter_id = 1;"

        let cmd = sut.build()
        XCTAssertEqual(expectedCommand, cmd!)
    }



//    func testBuildWithCalculatePrefsShouldThrowIfParamsAreNotSet() {
//
//        sut.calculatePrefs = true
//        var cmd: String?
//
//        defer {
//            XCTAssertNil(cmd)
//        }
//        do {
//            cmd = try sut.build()
//        } catch AnimalQueryBuilder.Error.calculatePrefsMissingParams(let missingParam) {
//            Log.error("Missing param is: \(missingParam)")
//        } catch (let error) {
//
//        }
//    }


    func testCalculatePrefsCommandShouldReturnCommandWhenThereAreNoBuilderProperties() {

        let expectedCommand = "select * from animal as animal, calculatepreferences(animal, '0','0','0','0','0','0','0','0','0','0',0,0) where shelter_id = 1 order by calculatepreferences desc;"

        sut.calculatePrefs = true

        XCTAssertEqual(sut.build(), expectedCommand)
    }


    func testCalculatePrefsCommandShouldReturnCommandWhenParamsAreSet() {
        let expectedCommand = "select * from animal as animal, calculatepreferences(animal, '1','0','0','0','1','0','0','1','0','0',1,2) where shelter_id = 1 order by calculatepreferences desc;"

        sut.calculatePrefs = true

        sut.animalType = .dog
        sut.gender = .female
        sut.animalSize = .large
        sut.minAge = 1
        sut.maxAge = 2

        XCTAssertEqual(sut.build(), expectedCommand)

    }

    func testCalculatePrefsWithShelterIdReturnCommandForGivenShelterId() {
        let expectedCommand = "select * from animal as animal, calculatepreferences(animal, '0','1','0','1','0','1','0','0','1','0',4,10) where \(AnimalDBKey.shelterId) = 2 order by calculatepreferences desc;"

        sut.calculatePrefs = true

        sut.animalType = .cat
        sut.gender = .male
        sut.animalSize = .small
        sut.activity = .high
        sut.minAge = 4
        sut.maxAge = 10
        sut.shelterId = 2

        XCTAssertEqual(sut.build(), expectedCommand)

    }

    func testBuilderShouldAddLimitWhenSizeIsProvided() {
        let expectedCommand = "select * from animal as animal, calculatepreferences(animal, '0','1','0','1','0','1','0','0','1','0',4,10) where \(AnimalDBKey.shelterId) = 1 order by calculatepreferences desc limit 13;"

        sut.calculatePrefs = true

        sut.animalType = .cat
        sut.gender = .male
        sut.animalSize = .small
        sut.activity = .high
        sut.minAge = 4
        sut.maxAge = 10
        sut.shelterId = 1
        sut.size = 13

        XCTAssertEqual(expectedCommand, sut.build())
    }

    func testBuilderShouldProvideOffsetWhenSizeAndPageIsProvided() {

        let expectedCommand = "select * from animal as animal, calculatepreferences(animal, '0','1','0','1','0','1','0','0','1','0',4,10) where \(AnimalDBKey.shelterId) = 1 order by calculatepreferences desc limit 10 offset 30;"

        sut.calculatePrefs = true

        sut.animalType = .cat
        sut.gender = .male
        sut.animalSize = .small
        sut.activity = .high
        sut.minAge = 4
        sut.maxAge = 10
        sut.shelterId = 1
        sut.size = 10
        sut.page = 3

        XCTAssertEqual(expectedCommand, sut.build())

    }


    func testBuilderBuildsCommandsWithShelterIdWithouCalcPrefs() {
        let expectedCommand = "select * from animal where \(AnimalDBKey.shelterId) = 2;"

        sut.shelterId = 2

        XCTAssertEqual(expectedCommand, sut.build())

    }

    func testBuildBuildsCommandWithShelterIdAndNameAndGenderAndActivityAndTrainingAndVaccinationWithoutCalcPrefs() {
        let expectedCommand = "select * from animal where shelter_id = 1 and gender = 'MALE' and activity = 'HIGH' and training = 'ADVANCED' and vaccination = 'EXTENDED';"

        sut.shelterId = 1
        sut.gender = .male
        sut.activity = .high
        sut.training = .advanced
        sut.vaccination = .extended

        XCTAssertEqual(expectedCommand, sut.build())
    }

    func testBuildBuildsCommandWithNameFiltering(){
        let expectedCommand = "select * from animal where shelter_id = 1 and name ilike 'arn%';"

        sut.name = "arn"
        XCTAssertEqual(expectedCommand, sut.build())

    }

    func testQueryBuilderShouldBeAbleToParseRequestParamSize() {
        let params = [
            "animalSize": "small"
        ]

        let sut = AnimalQueryBuilder(params: params, shelterId: 1)
        XCTAssertEqual(sut.animalSize, Size.small)
    }

    func testQueryBuilderShouldBeAbleToParseRequestParamsSizeLarge() {
        let params = [
            "animalSize": "medium"
        ]
        let sut = AnimalQueryBuilder(params: params, shelterId: 1)
            XCTAssertEqual(sut.animalSize, Size.medium)
    }

    func testQueryBuilderShouldBeAbleToParseSetOfParams() {
        let params = [
            "animalSize": "Large",
            "gender": "Female",
            "name" : "Ka",
            "activity" : "low",
            "species" : "DOG",
            "calculatePrefs": "true",
            "shelterId": "1",
            "sterilization": "STERILIZED",
            "training": "Unknown",
            "animalStatus": "FOR_aDoPtion"
        ]

        let sut = AnimalQueryBuilder(params: params, shelterId: 1)

        XCTAssertEqual(sut.animalSize, Size.large)
        XCTAssertEqual(sut.gender, Gender.female)
        XCTAssertEqual(sut.name, "Ka")
        XCTAssertEqual(sut.activity, Activity.low)
        XCTAssertEqual(sut.animalType, Species.dog)
        XCTAssertTrue(sut.calculatePrefs!)
        XCTAssertEqual(sut.shelterId, 1)
        XCTAssertEqual(sut.sterilization, Sterilization.sterilized)
        XCTAssertEqual(sut.training, Training.unknown)
        XCTAssertEqual(sut.animalStatus, AnimalStatus.forAdoption)

    }


    static var allTests : [(String, (AnimalQueryBuilderTests) -> () throws -> Void)] {
        return [("testBuilderOptionallyTakesShelterId", testBuilderOptionallyTakesShelterId),
                ("testBuilderOptionallyTakesCalculatePrefsParams", testBuilderOptionallyTakesCalculatePrefsParams),
                ("testBuilderOptionallyTakesAnimalTypeParam", testBuilderOptionallyTakesAnimalTypeParam),
                ("testBuilderOptionallyTakesGenderParam", testBuilderOptionallyTakesGenderParam),
                ("testBuilderOptionallyTakesActivityParam", testBuilderOptionallyTakesActivityParam),
                ("testBuilderOptionallyTakesSterilizationParam", testBuilderOptionallyTakesSterilizationParam),
                ("testBuilderOptionallyTakesTrainingParam", testBuilderOptionallyTakesTrainingParam),
                ("testBuilderOptionallyTakesVaccinationParam", testBuilderOptionallyTakesVaccinationParam),
                ("testBuilderOptionallyTakesAnimalStatusParam", testBuilderOptionallyTakesAnimalStatusParam),
                ("testBuilderOptionallyTakesSizeParam", testBuilderOptionallyTakesSizeParam),
                ("testBuilderOptionallyTakesPageParam", testBuilderOptionallyTakesPageParam),
                ("testBuilderOptionallyTakesMaxAgeParam", testShouldReturnDefaultQueryWithNoParams),
                ("testCalculatePrefsCommandShouldReturnCommandWhenThereAreNoBuilderProperties", testCalculatePrefsCommandShouldReturnCommandWhenThereAreNoBuilderProperties),
                ("testCalculatePrefsCommandShouldReturnCommandWhenParamsAreSet", testCalculatePrefsCommandShouldReturnCommandWhenParamsAreSet),
                ("testBuilderShouldAddLimitWhenSizeIsProvided", testBuilderShouldAddLimitWhenSizeIsProvided),
                ("testBuilderShouldProvideOffsetWhenSizeAndPageIsProvided", testBuilderShouldProvideOffsetWhenSizeAndPageIsProvided),
                ("testBuilderBuildsCommandsWithShelterIdWithouCalcPrefs", testBuilderBuildsCommandsWithShelterIdWithouCalcPrefs),
                ("testBuildBuildsCommandWithShelterIdAndNameAndGenderAndActivityAndTrainingAndVaccinationWithoutCalcPrefs", testBuildBuildsCommandWithShelterIdAndNameAndGenderAndActivityAndTrainingAndVaccinationWithoutCalcPrefs),
                ("testBuildBuildsCommandWithShelterIdAndNameAndGenderAndActivityAndTrainingAndVaccinationWithoutCalcPrefs", testBuildBuildsCommandWithShelterIdAndNameAndGenderAndActivityAndTrainingAndVaccinationWithoutCalcPrefs),
                ("testBuildBuildsCommandWithNameFiltering", testBuildBuildsCommandWithNameFiltering),
                ("testQueryBuilderShouldBeAbleToParseRequestParamSize", testQueryBuilderShouldBeAbleToParseRequestParamSize),
                ("testQueryBuilderShouldBeAbleToParseRequestParamsSizeLarge", testQueryBuilderShouldBeAbleToParseRequestParamsSizeLarge),
                ("testQueryBuilderShouldBeAbleToParseRequestParamsSizeLarge", testQueryBuilderShouldBeAbleToParseRequestParamsSizeLarge)


               ]
    }
}
