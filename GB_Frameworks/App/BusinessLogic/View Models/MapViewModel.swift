//
//  MainViewModel.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 22.05.2022.
//

import Foundation
import CoreLocation
import RealmSwift

final class MapViewModel {
    private var coordinates: [RealmTrack] = []
    
    weak var coordinator: MainCoordinator?
    
    var trackState: TrackState = .stop
    
    func onAuth() {
        coordinator?.showAuthModule()
    }
    
    func startTrack() {
        guard trackState != .run else { return }
        trackState = .run
        self.coordinates.removeAll()
    }
    
    func stopTrack() {
        guard trackState == .run else { return }
        trackState = .stop
        try? RealmService.deleteAll()
        try? RealmService.save(items: self.coordinates)
    }
    
    func saveCoordinates(coordinates: CLLocationCoordinate2D) {
        guard trackState == .run else { return }
        let realmData = RealmTrack(coordinates: coordinates)
        self.coordinates.append(realmData)
    }
    
    func showLastTrack(completion: @escaping (Results<RealmTrack>?) -> Void) {
        let data = try? RealmService.load(typeOf: RealmTrack.self)
        completion(data)
    }
}
