//
//  RealmTrack.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 20.05.2022.
//

import Foundation
import RealmSwift
import CoreLocation

class RealmTrack: Object {
    @Persisted(indexed: true) var pointID: String = UUID().uuidString
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    override static func primaryKey() -> String? {
        return "pointID"
    }
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }
}
