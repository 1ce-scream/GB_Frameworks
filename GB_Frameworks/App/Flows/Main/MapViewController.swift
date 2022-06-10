//
//  ViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 15.05.2022.
//

import UIKit
import RxSwift
import GoogleMaps

final class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var stopTrackButton: UIButton!
    @IBOutlet weak var startTrackButton: UIButton!
    @IBOutlet weak var removeMarkerButton: UIButton!
    @IBOutlet weak var lastTrackButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var selfyButton: UIButton!
    
// MARK: - Properties
    private let zoom: Float = 17.0
    private let strokeWidth: CGFloat = 5
    private let myLocationButtonInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    private let mapPadding: CGFloat = 30.0
    
    private let disposeBag = DisposeBag()
    private let locationManager = LocationManager.instance

    private var manualMarker: GMSMarker?
    private var trackMarker: GMSMarker?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    private lazy var alertHelper = AlertsHelper(viewController: self)
    
    var viewModel: MapViewModel?
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureLocationManager()
        configureButtons()
    }

// MARK: - View configurations
    private func configureButtons() {
        removeMarkerButton.addTarget(self,
                                     action: #selector(removeMarker),
                                     for: .touchUpInside)
        
        startTrackButton.addTarget(self,
                                   action: #selector(startTrack),
                                   for: .touchUpInside)
        startTrackButton.tintColor = .systemGreen
        
        stopTrackButton.addTarget(self,
                                  action: #selector(stopTrack),
                                  for: .touchUpInside)
        stopTrackButton.tintColor = .systemRed
        
        lastTrackButton.addTarget(self,
                                  action: #selector(showLastTrack),
                                  for: .touchUpInside)
        lastTrackButton.tintColor = .systemTeal
        
        logOutButton.addTarget(self,
                               action: #selector(tapLogoutButton),
                               for: .touchUpInside)
        
        // MARK: Comment to use UIImagePicker
        selfyButton.addTarget(self,
                              action: #selector(tapSelfyButton),
                              for: .touchUpInside)
        // MARK: Uncomment to use UIImagePicker
//        selfyButton.addTarget(self,
//                              action: #selector(showImagePicker),
//                              for: .touchUpInside)
        selfyButton.tintColor = .systemMint
    }
    
    private func configureRouteView(path: GMSMutablePath?) {
        if let extPath = path {
            routePath = extPath
        } else {
            routePath = GMSMutablePath()
        }
        route = GMSPolyline(path: routePath)
        route?.strokeColor = .systemBlue
        route?.strokeWidth = strokeWidth
        route?.map = mapView
    }

// MARK: - Private functions
    private func addMarker(coordinate: CLLocationCoordinate2D, color: UIColor) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
        self.manualMarker = marker
    }
    
    private func addTrackMarker(coordinate: CLLocationCoordinate2D) {
        if trackMarker == nil {
            createTrackMarker(coordinate: coordinate)
        } else {
            trackMarker?.map = nil
            trackMarker = nil
            createTrackMarker(coordinate: coordinate)
        }
    }
    
    private func createTrackMarker(coordinate: CLLocationCoordinate2D) {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        let image = viewModel?.loadPhotoFromFiles()
//        let image = viewModel?.LoadPhotoFromUserDefaults()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = view.frame.size.width / 2
        view.clipsToBounds = true
        view.image = image
        
        let marker = GMSMarker(position: coordinate)
        marker.iconView = view
        marker.map = mapView
        self.trackMarker = marker
    }
}

//MARK: - Configurations
extension MapViewController {
    private func configureMap() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.padding = myLocationButtonInset
    }
    
    private func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .subscribe(
                onNext: { [weak self] location in
                    guard let location = location else { return }
                    guard let self = self else { return }
                    
                    self.routePath?.add(location.coordinate)
                    self.route?.path = self.routePath
    
                    let position = GMSCameraPosition.camera(withTarget: location.coordinate,
                                                            zoom: self.zoom)
                    self.mapView.animate(to: position)
                    
                    self.viewModel?.saveCoordinates(coordinates: location.coordinate)
                    
                    if self.viewModel?.trackState == .run {
                        self.addTrackMarker(coordinate: location.coordinate)
                        return
                    } else {
                        self.locationManager.stopUpdatingLocation()
                    }
                },
                onError: { error in
                    print(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}

//MARK: - Actions
extension MapViewController {
    @objc func removeMarker() {
        manualMarker?.map = nil
        manualMarker = nil
    }
    
    @objc func startTrack() {
        mapView.clear()
        configureRouteView(path: nil)
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        viewModel?.startTrack()
    }
    
    @objc func stopTrack() {
        locationManager.stopUpdatingLocation()
        viewModel?.stopTrack()
        mapView.clear()
    }
    
    @objc func showLastTrack() {
        guard
            viewModel?.trackState == .stop
        else {
            let action = UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
                self?.locationManager.stopUpdatingLocation()
                self?.viewModel?.stopTrack()
                self?.mapView.clear()
            }
            alertHelper.showAlert(title: "Внимание!",
                                  message: "Сначала необходимо остановить трэк",
                                  externalAction: action)
            return
        }
        
        mapView.clear()
        routePath?.removeAllCoordinates()
        
        viewModel?.showLastTrack { items in
            items?.forEach { item in
                let coordinate = CLLocationCoordinate2D(latitude: item.latitude,
                                                        longitude: item.longitude)
                self.routePath?.add(coordinate)
            }
            
            guard let path = self.routePath else { return }

            self.configureRouteView(path: path)
            let bounds = GMSCoordinateBounds(path: path)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds,
                                                           withPadding: self.mapPadding))
        }
    }
    
    @objc func tapLogoutButton() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        viewModel?.onAuth()
    }
    
    @objc func tapSelfyButton() {
        viewModel?.onPhoto()
    }
    
    @objc func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera)
        else { return }
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            addMarker(coordinate: coordinate, color: .systemGreen)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension MapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let image = self?.extractImage(from: info) else { return }
            self?.viewModel?.onSelfy(photo: image)
        }
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
