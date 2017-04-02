//
//  LocationService.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 02.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import CoreLocation
import Foundation

let minimumDistanceToUpdate = 10.0

class LocationService: NSObject, CLLocationManagerDelegate {
    public static let sharedManager = LocationService()
    private var locationManager: CLLocationManager
    public var currentLocation: CLLocation?

    private override init() {
        locationManager = CLLocationManager()

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    deinit {
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("track location")
        if !locations.isEmpty {
            if let dist = currentLocation?.distance(from: locations[0]) {
                if dist > minimumDistanceToUpdate {
                    currentLocation = locations[0]
                    print("track location send notification")
                    NotificationCenter.default.post(name: Notification.Name.StreamTestLocationUpdated,
                                                    object: currentLocation)
                }
            } else {
                currentLocation = locations[0]
                print("track location send notification")
                NotificationCenter.default.post(name: Notification.Name.StreamTestLocationUpdated,
                                                object: currentLocation)
            }
        }
    }
}
