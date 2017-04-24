//
//  ScheduleModel.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import ObjectMapper
import RealmSwift

public class ScheduleModel: SerializableObject {
    dynamic var title: String = ""
    dynamic var period: String = ""
    dynamic var group: Int = 0

    var calcTitle: String {
        if title.characters.isEmpty {
            return "пн-вс: \(period)"
        } else if period.characters.isEmpty {
            return "\(title)"
        }
        return "\(title): \(period)"
    }

    required convenience public init?(map: Map) {
        self.init()
    }

    convenience public init(title: String, period: String, group: Int) {
        self.init()
        self.title = title
        self.period = period
        self.group = group
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        if map.mappingType == .toJSON {
            title >>> map["title"]
            period >>> map["period"]
            group >>> map["group"]
        } else {
            title <- map["title"]
            period <- map["period"]
            group <- map["group"]
        }
    }

    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
