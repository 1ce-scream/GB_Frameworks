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
    private let photoName = "Selfie"
    private var coordinates: [RealmTrack] = []
    
    weak var coordinator: MainCoordinator?
    
    var trackState: TrackState = .stop
    
    func onAuth() {
        coordinator?.showAuthModule()
    }
    
    func onPhoto() {
        coordinator?.showPhotoModule()
    }
}

// MARK: - Track functions
extension MapViewModel {
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

// MARK: - Photo functions
extension MapViewModel {
    func LoadPhotoFromUserDefaults() -> UIImage? {
        guard
            let data = UserDefaults.standard.data(forKey: photoName)
        else { return nil }
        
        var decoded: Data?
        
        do {
            decoded = try PropertyListDecoder().decode(Data.self, from: data)
        } catch let error {
            print("Couldn`t load photo from user defaults", error)
        }
        
        if let decoded = decoded {
            return UIImage(data: decoded)
        } else {
            return UIImage(named: "walter-white")
        }
    }
    
    func loadPhotoFromFiles() -> UIImage? {
        let fileDirectory = FileManager.SearchPathDirectory.applicationSupportDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(fileDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let photoURL = URL(fileURLWithPath: dirPath).appendingPathComponent(photoName)
            let photo = UIImage(contentsOfFile: photoURL.path)
            return photo
        } else {
            return nil
        }
    }
}
