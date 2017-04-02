//
//  String+Serialization.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 22/02/2017.
//  Copyright © 2017 Turing. All rights reserved.
//

import Foundation
import ObjectMapper

public extension String {
    public func serialize<T: SerializableObject>(_ asType: T.Type, fromItem: String) -> [T]? {
        if let data = self.data(using: .utf8) {
            do {
                let jsons = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]

                if let subItems = jsons?[fromItem] as? [[String: Any]] {
                    if !subItems.isEmpty {
                        var res = [T]()
                        for json in subItems {
                            var item = T(value: json)
                            item = Mapper(context: nil, shouldIncludeNilValues: true)
                                .map(JSON: json, toObject: T(value: json))
                            res.append(item)
                        }
                        return res
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public func serialize<T: SerializableObject>(_ asType: T.Type) -> T? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]

                if json != nil {
                    return Mapper(context: nil, shouldIncludeNilValues: true)
                        .map(JSON: json!, toObject: T(value: json!))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public func serialize<T: SerializableObject>(_ asType: T.Type) -> [T]? {
        if let data = self.data(using: .utf8) {
            do {
                let jsons = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                if (jsons != nil) && ((jsons?.count)! > 0) {
                    var res = [T]()
                    for json in jsons! {
                        var item = T(value: json)
                        item = Mapper(context: nil, shouldIncludeNilValues: true)
                            .map(JSON: json, toObject: T(value: json))
                        res.append(item)
                    }
                    return res
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
