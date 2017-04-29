//
//  PlaceLocationModel.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import CoreLocation
import MapKit
import ObjectMapper
import RealmSwift

class PlaceLocationModel: SerializableObject {
    dynamic var lat: Double = 0.0
    dynamic var lng: Double = 0.0

    required convenience init?(map: Map) {
        self.init()
    }

    var distance: String {
        /*if let curLoc = LocationService.sharedManager.currentLocation {
            let loc = CLLocation(latitude: lat, longitude: lng)
            let dist = curLoc.distance(from: loc)

            let formatter = MKDistanceFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.units = .metric
            formatter.unitStyle = .abbreviated
            return formatter.string(fromDistance: dist)
        }*/
        return "Геолокация не включена"
    }

    override func mapping(map: Map) {
        super.mapping(map: map)

        if map.mappingType == .toJSON {
            lat >>> map["lat"]
            lng >>> map["lng"]
        } else {
            lat <- map["lat"]
            lng <- map["lng"]
        }
    }
}
