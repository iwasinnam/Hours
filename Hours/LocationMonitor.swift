//
//  LocationManager.swift.swift
//  Hours
//
//  Created by Ariel Steiner on 10/12/2021.
//

import Foundation

import CoreLocation

class LocationMonitor : NSObject, ObservableObject {
    static let regionIdentifier = "ariel.hours.workplace"

    @Published var authState : CLAuthorizationStatus
    @Published var suggestedPlacemark: CLPlacemark?
    var monitoredPlaceName : String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "placeName")
        }
        get {
            UserDefaults.standard.string(forKey: "placeName")
        }
    }

    let locMan : CLLocationManager
    override init() {
        locMan = CLLocationManager()
        authState = locMan.authorizationStatus
        super.init()

        locMan.delegate = self
    }

    func requestAuthorization() {
        locMan.requestAlwaysAuthorization()
    }

    func locateCoordinates(addressString: String) {
        let geocoder = CLGeocoder()
        logger.log("determining location of \(addressString)")
        geocoder.geocodeAddressString(addressString) { [weak self] (placemarks, error) in
            if let error = error {
                logger.log("Couldn't determine cooridnates of \(addressString): \(error.localizedDescription)")
            }
            self?.suggestedPlacemark = placemarks?.first
        }
    }


    func setOfficeLocation(placemark: CLPlacemark) {
        monitoredPlaceName = [placemark.name, placemark.locality].compactMap { $0 }.joined(separator: ", ")
        logger.log("settings office location to \(self.monitoredPlaceName!)")

        suggestedPlacemark = nil
        let circularRegion = CLCircularRegion(
            center: placemark.location!.coordinate,
            radius: CLLocationDistance(200),
            identifier: Self.regionIdentifier)

        locMan.startMonitoring(for: circularRegion)
    }
}

extension LocationMonitor : CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authState = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        assert(region.identifier == Self.regionIdentifier)
        logger.log("Did enter workplace (\(self.monitoredPlaceName ?? "unkown"))")

        PersistenceController.shared.insertBeginWork()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        assert(region.identifier == Self.regionIdentifier)
        logger.log("Did exit workplace (\(self.monitoredPlaceName ?? "unknown")")

        PersistenceController.shared.insertEndWork()
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        logger.log("monitoring failed. \(error.localizedDescription). Not monitoring")

        monitoredPlaceName = nil

        if let monitored = locMan.monitoredRegions.first(where: { $0.identifier == Self.regionIdentifier }) {
            locMan.stopMonitoring(for: monitored)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.log("location manager failed. \(error.localizedDescription)")
    }
}
