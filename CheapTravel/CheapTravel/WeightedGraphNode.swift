//
//  WeightedGraphNode.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/17/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation
import GameplayKit

class WeightedGraphNode: GKGraphNode {
    
    //  MARK: Properties
    let place: Place
    var travelCost: [GKGraphNode: Float] = [:]
    
    init(place: Place) {
        self.place = place
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.place = Place(name: "", coordinates: Coordinates(lat: 0.0, long: 0.0))
        super.init()
    }
    
    override func cost(to node: GKGraphNode) -> Float {
        return travelCost[node] ?? 0
    }
    
    func addConnection(to node: GKGraphNode, bidirectional: Bool = true, weight: Float) {
        self.addConnections(to: [node], bidirectional: bidirectional)
        travelCost[node] = weight
        guard bidirectional else { return }
        (node as? WeightedGraphNode)?.travelCost[self] = weight
    }
}
