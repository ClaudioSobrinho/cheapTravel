//
//  DataFetcher.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation

protocol ConnectionsDataFetcherProtocol {
    func fetchConnections(completion: ([Connection]?,_ errorMessage: String?)->())
}

class ConnectionDataFetcher: ConnectionsDataFetcherProtocol {
    
    func fetchConnections(completion: ([Connection]?,_ errorMessage: String?)->()) {
        guard let path = Bundle.main.path(forResource: "connections", ofType: "json") else {
            completion(nil, "There is a problem in fetching places for you.")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let jsonResult = json as? [String: Any] else {
                completion(nil, "There is a problem in fetching places for you.")
                return
            }
            guard let results = jsonResult["connections"] as? [[String: Any]] else { return }
            completion(self.connectionsListFrom(results: results), nil)            
        } catch {
            completion(nil, "There is a problem in fetching places for you.")
        }
    }
    
    private func connectionsListFrom(results: [[String: Any]]) -> [Connection] {
        var connections = [Connection]()
        for connection in results {
            guard let coordinatesList = connection["coordinates"] as? [String: Any],
                let origin = coordinatesList["from"] as? [String: Any],
                let destination = coordinatesList["to"] as? [String: Any] else{
                    continue
            }

            let originCoordinates = Coordinates(lat: origin["lat"] as! Double, long: origin["long"] as! Double)
            let destinationCoordinates = Coordinates(lat: destination["lat"] as! Double, long: destination["long"] as! Double)
            
            let originPlace = Place(name: connection["from"] as! String, coordinates: originCoordinates)
            let destinationPlace = Place(name: connection["to"] as! String, coordinates: destinationCoordinates)
            
            let connection = Connection(origin: originPlace, destination: destinationPlace, price:connection["price"] as! Int)
            connections.append(connection)
        }
        return connections
    }
    
}
