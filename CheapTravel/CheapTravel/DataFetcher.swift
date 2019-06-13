//
//  DataFetcher.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation

protocol ConnectionsDataFetcherProtocol {
    func fetchData(completion: (([Connection],[Place])?,_ errorMessage: String?)->())
    func fetchRemoteData(completion: @escaping (([Connection],[Place])?,_ errorMessage: String?)->())
}

class ConnectionDataFetcher: ConnectionsDataFetcherProtocol {

    //  MARK: Properties
    private static let baseURL = "https://raw.githubusercontent.com/TuiMobilityHub/"
    private static let connectionsJsonURL = "ios-code-challenge/master/connections.json"
    
    //  MARK: Functions
    func fetchRemoteData(completion: @escaping (([Connection],[Place])?,_ errorMessage: String?)->()) {
        guard let url = URL(string: "\(ConnectionDataFetcher.baseURL)\(ConnectionDataFetcher.connectionsJsonURL)") else {
            completion(nil, "🛑🌐 There is a problem in fetching places for you. 🌐🛑")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response
            , error) in
            guard let data = data else {
                completion(nil, "🛑🌐 There is a problem in fetching places for you. 🌐🛑")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                guard let jsonResult = json as? [String: Any] else { return }
                guard let results = jsonResult["connections"] as? [[String: Any]] else { return }
                completion(self.dataFrom(results: results), nil)
            } catch let err {
                completion(nil, "🛑🔖 \(err) 🔖🛑")
            }
            }.resume()
    }
    
    func fetchData(completion: (([Connection],[Place])?,_ errorMessage: String?)->()) {
        guard let path = Bundle.main.path(forResource: "connections", ofType: "json") else {
            completion(nil, "🛑🔖 There is a problem in fetching places for you. 🔖🛑")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            guard let jsonResult = json as? [String: Any] else {
                completion(nil, "🛑🔖 There is a problem in fetching places for you. 🔖🛑")
                return
            }
            guard let results = jsonResult["connections"] as? [[String: Any]] else { return }
            completion(self.dataFrom(results: results), nil)
        } catch {
            completion(nil, "🛑🔖 There is a problem in fetching places for you. 🔖🛑")
        }
    }
    
    private func dataFrom(results: [[String: Any]]) -> ([Connection], [Place]) {
        var connections = [Connection]()
        var places = [Place]()
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
            
            if !places.contains(originPlace) {
                places.append(originPlace)
            }
            
            if !places.contains(destinationPlace) {
                places.append(destinationPlace)
            }
            connections.append(connection)
        }
        return (connections, places)
    }
    
}
