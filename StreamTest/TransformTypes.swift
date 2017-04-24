//
//  TransformTypes.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 25.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

open class CustomDateTransform: TransformType {
    //2016-10-21T01:00:57+03:00
    private let format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZZ"
    public typealias Object = Date
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeStr = value as? String {
            return timeStr.toDate(format: format)
        }

        return nil
    }

    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.toStringWith(format: format)
        }
        return nil
    }
}

open class SheduleTransform: TransformType {
    public typealias Object = List<ScheduleModel>
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> List<ScheduleModel>? {
        //"пн.-пт.: 08.00-20.00; сб.: 09.00-18.00, обед: 14.00-15.00"
        if let stringValue = value as? String {
            let shedulePairs = stringValue.components(separatedBy: ";")
            let res = List<ScheduleModel>()
            for i in 0..<shedulePairs.count {
                let values = shedulePairs[i].components(separatedBy: ",")
                for value in values {
                    let datas = value.components(separatedBy: ":")
                    if (datas.count == 2) {
                        let shedule = ScheduleModel(title: datas[0].trim(), period: datas[1].trim(), group: i)
                        res.append(shedule)
                    } else if (datas.count > 1) {
                        let shedule = ScheduleModel(title: "", period: value, group: i)
                        res.append(shedule)
                    }
                }
            }
            return res
        }

        return nil
    }

    open func transformToJSON(_ value: List<ScheduleModel>?) -> String? {
        var res = ""
        var group = 0
        var sep = ""
        for item in value! {
            res += "\(sep)\(item.title):\(item.period)"
            sep = group < item.group ? "," : ";"
            group = item.group
        }
        return res
    }
}

open class ListTransform<T: RealmSwift.Object>: TransformType where T: BaseMappable {

    public init() { }

    public typealias Object = List<T>
    public typealias JSON = [Any]

    public func transformFromJSON(_ value: Any?) -> List<T>? {
        if let objects = Mapper<T>().mapArray(JSONObject: value) {
            let list = List<T>()
            list.append(objectsIn: objects)
            return list
        }
        return nil
    }

    public func transformToJSON(_ value: Object?) -> JSON? {
        return value?.flatMap { $0.toJSON() }
    }

}
