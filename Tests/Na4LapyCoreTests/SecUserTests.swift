//
//  SecUserTests.swift
//  Na4lapyAPI
//
//  Created by Wojciech Bilicki on 04/03/2017.
//
//

import XCTest

import Foundation
import SwiftyJSON
import LoggerAPI

@testable import Na4LapyCore

class SecUserTests: XCTestCase {

    func testConstructorShouldReturnsNilWithEmptyDictionary() {

        var secUser: SecUser?

        let expectedMissingParams = JSON([SecUser.oldPasswordKey: JSON.missingParamJsonErrorString, SecUser.repeatNewPasswordKey : JSON.missingParamJsonErrorString, SecUser.newPasswordKey: JSON.missingParamJsonErrorString])

        do {
             let json = JSON(nilLiteral: ())
            secUser = try SecUser(withJSON: json)
        } catch (let error) {
            XCTAssertTrue(error is SecUserError)

            switch error as! SecUserError {
            case .missingParams(let json):
                XCTAssertEqual(json, expectedMissingParams)
            default:
                XCTFail("Wrong error type")
            }
        }
        XCTAssertNil(secUser)

    }

    func testConstructorShouldReturnNilWithNewPasswordMissing() {

        let json = JSON([SecUser.newPasswordKey: "newPassword"])
        let expectedMissingParams = JSON(
            [SecUser.oldPasswordKey: JSON.missingParamJsonErrorString,
             SecUser.repeatNewPasswordKey: JSON.missingParamJsonErrorString])
        var secUser: SecUser?
        do {
             secUser = try SecUser(withJSON: json)
        } catch (let error) {
            XCTAssertTrue(error is SecUserError)
            switch error as! SecUserError{
            case .missingParams(let json):
                XCTAssertEqual(json, expectedMissingParams)
            default:
                XCTFail("Wrong error type")
            }
        }

        XCTAssertNil(secUser)
    }

    func testConstructorShouldThrowIfNewPasswordIsSameAsOld() {
        let json = JSON(
            [SecUser.newPasswordKey: "newPassword",
             SecUser.oldPasswordKey: "newPassword",
             SecUser.repeatNewPasswordKey: "newPassword"])
        let expectedErrorJson = JSON([SecUser.newPasswordKey: "Can't be same as old password"])
        var secUser: SecUser?

        do {
            secUser = try SecUser(withJSON: json)
        } catch let(error) {
            XCTAssertTrue(error is SecUserError)
            let error = error as! SecUserError
            switch error {
            case .newPasswordSameAsOld(let json):
                XCTAssertEqual(json, expectedErrorJson)
            default:
                XCTFail("Wrong error type")
            }

        }

        XCTAssertNil(secUser)

    }


    func testConstructorShouldThrowIfNewPasswordDifferentThanRepeatNewPassword() {
        let json = JSON([SecUser.newPasswordKey: "newPassword",
                         SecUser.oldPasswordKey: "oldPassword",
                         SecUser.repeatNewPasswordKey : "notNewPassword"])

        let expectedErrorJson = JSON([SecUser.repeatNewPasswordKey: "Differs from newPassword"])

        var secUser: SecUser?

        do {
            secUser = try SecUser(withJSON: json)
        } catch (let error) {
            XCTAssertTrue(error is SecUserError)
            let error = error as! SecUserError

            switch error {
            case .newPasswordAndRepeatNotTheSame(let json):
                XCTAssertEqual(json, expectedErrorJson)
            default:
                XCTFail("Wrong error type")
            }
        }

        XCTAssertNil(secUser)
    }


    func testConstructorExecutesProperly() {
        let json = JSON([SecUser.newPasswordKey: "newPassword",
                         SecUser.oldPasswordKey: "oldPassword",
                         SecUser.repeatNewPasswordKey : "newPassword"])

        var secUser: SecUser?
        do {
            secUser = try SecUser(withJSON: json)
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }

        XCTAssertEqual(secUser?.oldPassword, "oldPassword")
        XCTAssertEqual(secUser?.newPassword, "newPassword")
        XCTAssertEqual(secUser?.repeatNewPassword, "newPassword")
    }

    static var allTests : [(String, (SecUserTests) -> () throws -> Void)] {
        return [
            ("testConstructorShouldReturnsNilWithEmptyDictionary", testConstructorShouldReturnsNilWithEmptyDictionary),
            ("testConstructorShouldReturnNilWithNewPasswordMissing",
             testConstructorShouldReturnNilWithNewPasswordMissing)
        ]
    }

}


class JSONExtensionTests: XCTestCase {


    static var allTests : [(String, (JSONExtensionTests) -> () throws -> Void)] {
        return [("testgetMissinParamsForNilJson",
                 testgetMissinParamsForNilJson)
        ]
    }


    func testgetMissinParamsForNilJson(){
        let json = JSON(nilLiteral: ())

        XCTAssertEqual(
            (json.getMissingParams(forKeys: [SecUser.oldPasswordKey, SecUser.newPasswordKey, SecUser.repeatNewPasswordKey])),
            JSON([SecUser.oldPasswordKey: JSON.missingParamJsonErrorString, SecUser.repeatNewPasswordKey : JSON.missingParamJsonErrorString, SecUser.newPasswordKey : JSON.missingParamJsonErrorString]))
    }

    func testGetMissingParamsForIncompleteJson() {
        let json = JSON([SecUser.newPasswordKey: "AAAA"])

        let missingParams = json.getMissingParams(forKeys: [SecUser.oldPasswordKey, SecUser.newPasswordKey, SecUser.repeatNewPasswordKey])

        let expectedMissingParams = JSON([SecUser.oldPasswordKey: JSON.missingParamJsonErrorString, SecUser.repeatNewPasswordKey : JSON.missingParamJsonErrorString])

        XCTAssertEqual(missingParams, expectedMissingParams)
    }

}
