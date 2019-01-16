//
//  FirstScreenViewModelTests.swift
//  CheapTravelTests
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import XCTest
@testable import CheapTravel

class FirstScreenViewModelTests: XCTestCase {

    var sut: FirstScreenViewModel!
    var mockConnectionsDataFetcher: MockConnectionsDataFetcher!
    
    override func setUp() {
        super.setUp()
        sut = FirstScreenViewModel(dataFetcher: MockConnectionsDataFetcher())
        mockConnectionsDataFetcher = MockConnectionsDataFetcher()
        sut.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockConnectionsDataFetcher = nil
    }
    
    func testOutputAttributes() {
        XCTAssertEqual(sut.title, "Cheap Flights")
    }
    
//    func testDataModelForIndexPath() {
//        let tableModel = tableDataModel()
//        let indexPath = IndexPath(row: 0, section: 0)
//        XCTAssertEqual(tableModel[0], sut.tableCellDataModelForIndexPath(indexPath))
//    }
//    
//    func tableDataModel() -> [PlaceCellDataModel] {
//        var dataModel = [PlaceCellDataModel]()
//        for place in mockPlaceDataFetcher.places {
//            dataModel.append(PlaceCellDataModel(place: place))
//        }
//        return dataModel
//    }
    
}

// MARK: MockPlaceDataFetcher
/// A mock for data fetcher to provide test data.
class MockConnectionsDataFetcher: ConnectionsDataFetcherProtocol {
    
    var connections = [Connection]()
    var places = [Place]()
    
    init() {
        let firstOriginPlace = Place(name: "London", coordinates: Coordinates(lat: 51.5285582, long: -0.241681))
        let firstDestinationPlace = Place(name: "Tokyo", coordinates: Coordinates(lat: 35.652832, long: 139.839478))
        let firstConnection = Connection(origin: firstOriginPlace, destination: firstDestinationPlace, price: 600)
        connections.append(firstConnection)
        places.append(firstOriginPlace)
        places.append(firstDestinationPlace)
        let secondOriginPlace = Place(name: "London", coordinates: Coordinates(lat: 51.5285582, long: -0.241681))
        let secondDestinationPlace = Place(name: "Porto", coordinates: Coordinates(lat: 41.14961, long: -8.61099))
        let secondConnection = Connection(origin: secondOriginPlace, destination: secondDestinationPlace, price: 50)
        connections.append(secondConnection)
        places.append(secondDestinationPlace)
    }
    
    func fetchData(completion: (([Connection],[Place])?,_ errorMessage: String?)->()) {
        completion((connections, places), nil)
    }
}
