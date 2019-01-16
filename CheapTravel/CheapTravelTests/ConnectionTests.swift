//
//  ConnectionTests.swift
//  CheapTravelTests
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import XCTest
@testable import CheapTravel

class ConnectionTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAttributes() {
        let originCoordinates = Coordinates(lat: 51.5285582, long: -0.241681)
        let destinationCoordinates = Coordinates(lat: 35.652832, long: 139.839478)
        let originPlace = Place(name: "London", coordinates: originCoordinates)
        let destinationPlace = Place(name: "Tokyo", coordinates: destinationCoordinates)
        let price = 600
        let connection = Connection(origin: originPlace, destination: destinationPlace, price:price)
        XCTAssertEqual(connection.origin, originPlace)
        XCTAssertEqual(connection.destination, destinationPlace)
        XCTAssertEqual(connection.price, 600)
    }
}
