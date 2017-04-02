//
//  PartnerModel.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import ObjectMapper
import RealmSwift

class PartnerModel: SerializableObject {
    dynamic var id: String = ""
    dynamic var name: String = ""

    required convenience init?(map: Map) {
        self.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    // Specify properties to ignore (Realm won't persist these)

    //  override static func ignoredProperties() -> [String] {
    //    return []
    //  }
}
