//
//  SelfieViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 09.06.2022.
//

import UIKit

final class SelfyViewController: UIViewController {

    @IBOutlet weak var selfyImageView: UIImageView!
    @IBOutlet weak var savePhotoButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    var viewModel: PhotoViewModel?
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupButtons()
    }
    
    private func setupImageView() {
        selfyImageView.contentMode = .scaleAspectFit
        selfyImageView.layer.cornerRadius = 8
        selfyImageView.clipsToBounds = true
        selfyImageView.translatesAutoresizingMaskIntoConstraints = false
        selfyImageView.image = photo
    }
    
    private func setupButtons() {
        savePhotoButton.addTarget(self,
                                  action: #selector(tapSavePhotoButton),
                                  for: .touchUpInside)
        savePhotoButton.tintColor = .systemGreen
        takePhotoButton.addTarget(self,
                                  action: #selector(tapTakePhotoButton),
                                  for: .touchUpInside)
        takePhotoButton.tintColor = .systemTeal
    }
    
    @objc func tapSavePhotoButton() {
        guard let photo = self.photo else { return }
        viewModel?.savePhotoToUserDefaults(photo: photo)
        viewModel?.savePhotoToFiles(photo: photo)
        viewModel?.backToMap()
    }
    
    @objc func tapTakePhotoButton() {
        viewModel?.backToPhoto()
    }
    
}
