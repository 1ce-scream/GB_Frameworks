//
//  PhotoViewModel.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 09.06.2022.
//

import Foundation
import UIKit

final class PhotoViewModel {
    private let photoName = "Selfy"
    
    weak var coordinator: MainCoordinator?
    
    func backToMap() {
        coordinator?.backToMap()
    }
    
    func backToPhoto() {
        coordinator?.backToPhoto()
    }
    
    func onSelfy(photo: UIImage) {
        coordinator?.showSelfyModule(photo: photo)
    }
}

// MARK: - Save photo functions
extension PhotoViewModel {
    func savePhotoToUserDefaults(photo: UIImage) {
        guard
            let data = photo.jpegData(compressionQuality: 1.0)
        else { return }
        
        var encoded: Data?
        
        do {
            encoded = try PropertyListEncoder().encode(data)
        } catch let error {
            print("Couldn`t save photo", error)
        }
        
        UserDefaults.standard.set(encoded, forKey: photoName)
        print("Photo saved to user defaults")
    }
    
    func savePhotoToFiles(photo: UIImage) {
        guard
            let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                        in: .userDomainMask).first
        else { return }
        
        let fileName = photoName
        let fileURL = appDirectory.appendingPathComponent(fileName)
        
        guard let data = photo.jpegData(compressionQuality: 1.0) else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Old photo removed")
            } catch let removeError {
                print("Couldn`t remove old photo", removeError)
            }
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("Couldn`t save photo", error)
        }
        print("Photo saved to app files")
    }
}
