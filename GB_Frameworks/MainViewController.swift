//
//  ViewController.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 15.05.2022.
//

import UIKit
import CoreLocation
import GoogleMaps

class MainViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var removeMarkerButton: UIButton!
    @IBOutlet weak var updateLocationButton: UIButton!
    
    private let coordinate = CLLocationCoordinate2D(latitude: 55.753215,
                                                    longitude: 37.622504)
    private let zoom: Float = 17.0
    private let strokeWidth: CGFloat = 3
    private var locationManager: CLLocationManager?
    private var manualMarker: GMSMarker?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureLocationManager()
        configureButtons()
        
    }

    private func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
    }
    
    private func configureButtons() {
        removeMarkerButton.addTarget(self,
                                     action: #selector(removeMarker),
                                     for: .touchUpInside)
        removeMarkerButton.tintColor = .systemRed
        
        updateLocationButton.addTarget(self,
                                       action: #selector(updateLocation),
                                       for: .touchUpInside)
        updateLocationButton.tintColor = .systemBlue
    }
    
    private func addMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        self.manualMarker = marker
    }

    @objc func removeMarker() {
        manualMarker?.map = nil
        manualMarker = nil
    }
    
    @objc func updateLocation() {
        locationManager?.requestLocation()
         
        route?.map = nil
        route = GMSPolyline()
        route?.strokeWidth = strokeWidth
        routePath = GMSMutablePath()
        route?.map = mapView
        
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        locationManager?.requestLocation()
        print(locationManager?.location ?? 0,0)
    }
    
}

extension MainViewController: GMSMapViewDelegate {
     func mapView(_: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
         print(coordinate)

         if let manualMarker = manualMarker {
             manualMarker.position = coordinate
         } else {
             addMarker(coordinate: coordinate)
         }
     }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        routePath?.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate,
                                                zoom: zoom)
        mapView.animate(to: position)
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
