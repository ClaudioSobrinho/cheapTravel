//
//  FirstScreenViewModel.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/16/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation
import GameplayKit

class FirstScreenViewModel {
    
    var dataFetcher: ConnectionsDataFetcherProtocol!
    
    // Output
    var displayError:(String)->() = { _ in }
    var title = ""
    
    // Input
    var viewDidLoad: () -> () = { }
    
    private var connectionsDataModel: [Connection]! {
        didSet {
            configureOutput()
        }
    }
    private var placesDataModel: [Place]!{
        didSet {
            configureOutput()
        }
    }
    private let graph = GKGraph()
    private var nodesList = [WeightedGraphNode]()
    
    init(dataFetcher: ConnectionsDataFetcherProtocol) {
        self.dataFetcher = dataFetcher
        viewDidLoad = { [weak self] in
            self?.getData()
        }
    }
    
    private func getData() {
        dataFetcher.fetchData{ [weak self] (data, errorMessage) in
            guard let connections = data?.0, let places = data?.1 else {
                self?.displayError(errorMessage!)
                return
            }
            self?.connectionsDataModel = connections
            self?.placesDataModel = places
            self?.fillGraph()
        }
    }
    
    private func fillGraph() {
        for place in placesDataModel {
            let node = WeightedGraphNode(place: place)
            nodesList.append(node)
        }
        graph.add(nodesList)
        for connection in connectionsDataModel {
            guard let originNode = nodesList.first(where: { $0.place == connection.origin}),
                let destinationNode = nodesList.first(where: { $0.place == connection.destination }) else {
                    continue
            }
            originNode.addConnection(to: destinationNode, bidirectional: true, weight: Float(connection.price))
        }
    }
    
    private func configureOutput() {
        title = "Cheap Flights"
    }
    
    func findPlace(from text: String) -> Place? {
        return placesDataModel.first(where: { $0.name == text })
    }
    
    func findConnection(origin: String, destination: String) -> Connection? {
        let originPlace = placesDataModel.first(where: { $0.name == origin })
        let destinationPlace = placesDataModel.first(where: { $0.name == destination })
        return connectionsDataModel.first(where: { $0.origin == originPlace && $0.destination == destinationPlace ||
            $0.origin == destinationPlace && $0.destination == originPlace
        })
    }
    
    func findPath(origin: Place, destination: Place) -> ([Connection], Int?) {
        guard let originNode = nodesList.first(where: { $0.place == origin}),
            let destinationNode = nodesList.first(where: { $0.place == destination }) else {
                return ([], nil)
        }
        let path = graph.findPath(from: originNode, to: destinationNode)
        let cost = calculateCost(for: path)
        
        var connections = [Connection]()
        for i in 0..<(path.count-1) {
            let origin = nodesList.first(where: { $0 == path[i] })
            let destination = nodesList.first(where: { $0 == path[i+1] })
            if let connection = connectionsDataModel.first(where: {
                $0.origin == origin?.place && $0.destination == destination?.place ||
                $0.origin == destination?.place && $0.destination == origin?.place })
            {
                connections.append(connection)
            }
        }
        return (connections, cost)
    }
    
    private func calculateCost(for path: [GKGraphNode]) -> Int {
        var total: Float = 0
        for i in 0..<(path.count-1) {
            total += path[i].cost(to: path[i+1])
        }
        return Int(total)
    }
    
    //    MARK: Autocomplete
    func getAutocompletePossibilities() -> [String] {
        var possibilities = [String]()
        
        for place in placesDataModel {
            possibilities.append(place.name)
        }
        return possibilities
    }
    
}
