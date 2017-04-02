//
//  SerializableObject.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 22/02/2017.
//  Copyright © 2017 Turing. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

public class SerializableObject: Object, Mappable {
    // MARK: - Inits
    required public init() {
        super.init()
    }

    required convenience public init?(map: Map) {
        self.init()
    }

    required public override init(value: Any) {
        super.init(value:value)
    }

    required public init(value: Any, schema: RLMSchema) {
        super.init(value:value, schema:schema)
    }

    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    public func mapping(map: Map) {
    }

    public func setChildId() {
    }
}
