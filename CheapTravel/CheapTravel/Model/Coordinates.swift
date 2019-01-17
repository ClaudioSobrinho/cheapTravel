//
//  Coordinates.swift
//  CheapTravel
//
//  Created by Claudio Sobrinho on 1/15/19.
//  Copyright © 2019 Claudio Sobrinho. All rights reserved.
//

import Foundation
import MapKit

struct Coordinates: Equatable, Decodable {
    
    let lat: Double
    let long: Double
    
    func locationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
