//
//  PlaceTests.swift
//  CheapTravelTests
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import XCTest
@testable import CheapTravel

class PlaceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAttributes() {
        let coordinates = Coordinates(lat: 51.5285582, long: -0.241681)
        let place = Place(name: "London", coordinates: coordinates)
        XCTAssertEqual(place.coordinates.lat, 51.5285582)
        XCTAssertEqual(place.coordinates.long, -0.241681)
    }
}
