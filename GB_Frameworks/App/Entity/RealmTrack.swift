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
    @Persisted var id: String = ""
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
}
