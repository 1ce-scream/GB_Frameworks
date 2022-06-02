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
    
    private let zoom: Float = 17.0
    private let strokeWidth: CGFloat = 5
    private let myLocationButtonInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    private let mapPadding: CGFloat = 30.0
    
    private let disposeBag = DisposeBag()
    private let locationManager = LocationManager.instance

    private var manualMarker: GMSMarker?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    var alertHelper: AlertsHelper?
    var viewModel: MapViewModel?
    var onLogin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureLocationManager()
        configureButtons()
        
    }
    
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
                    guard self.viewModel?.trackState != .run else { return }
                    self.locationManager.stopUpdatingLocation()
                },
                onError: { error in
                    print(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
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
    
    private func addMarker(coordinate: CLLocationCoordinate2D, color: UIColor) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
        self.manualMarker = marker
    }
    
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
    
    @objc func tapLogoutButton() {
        UserDefaults.standard.set(false, forKey: "isLogin")
        onLogin?()
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
            alertHelper?.showAlert(title: "Внимание!",
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
}

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
