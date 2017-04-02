//
//  TuringServiceClient.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 15/02/2017.
//  Copyright © 2017 Turing. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

let defaultBaseURL: String = "http://gymn652.ru/tmp/"

public final class ServiceClient {
    // MARK: - Variables and Properties
    public static var baseUrl: String {
        return defaultBaseURL
    }

    // MARK: - Custom public/internal methods
    public static func setDefaultHeaders(_ request: RestServiceRequest) -> RestServiceRequest {
        return request
    }

    public static func getPlacesRequest(_ fileId: String) -> RestServiceRequest {
        return RestServiceRequest("\(baseUrl)unicorn.txt-\(fileId).json", method: .get)
    }

    // MARK: - Custom private methods
    private static func objectToJsonData(_ object:Any) -> Data? {
        var dict = [String: Any]()
        let otherSelf = Mirror(reflecting: object)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }
}
