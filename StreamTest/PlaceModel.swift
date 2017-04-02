//
//  PlaceModel.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 01.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import ObjectMapper
import RealmSwift

enum PlaceTypes: String {
    case
    atm = "atm",
    office = "office",
    partner = "partner"
}

class PlaceModel: SerializableObject {
    dynamic var id: String = ""
    dynamic var type: String = ""
    dynamic var title: String = ""
    dynamic var city: String = ""
    dynamic var region: String = ""
    dynamic var address: String = ""
    dynamic var location: PlaceLocationModel?
    dynamic var additionalInfo: String = ""
    dynamic var importantInfo: String = ""
    var schedules: List<ScheduleModel> = List<ScheduleModel>() //"пн.-пт.: 08.00-20.00; сб.: 09.00-18.00, обед: 14.00-15.00"
    dynamic var operations: String = ""
    dynamic var dateCreatedAt: Date = Date() // "2016-10-21T01:00:57+03:00"
    dynamic var dateModifiedAt: Date? // "2016-10-21T01:00:57+03:00",
    dynamic var partner: PartnerModel?

    var calcTitle: String {
        if type == PlaceTypes.atm.rawValue {
            return partner == nil ? "Собственный банкомат:\n \(title)" : "Банкомат партнера:\n \(title)"
        } else if type == PlaceTypes.office.rawValue {
            return partner == nil ? "Собственный офис:\n \(title)" : "Офис партнера:\n \(title)"
        } else if type == PlaceTypes.partner.rawValue {
            return "Партнер:\n \(title)"
        } else {
            return "Не известный тип:\n \(title)"
        }
    }

    var calcSchedule: String {
        if schedules.isEmpty {
            return "Расписание не задано"
        } else {
            var res = "Расписание:\n"
            var startGroup = 0
            for i in 0..<schedules.count {
                if startGroup == schedules[i].group {
                    res += "\(schedules[i].calcTitle) "
                } else {
                    startGroup = schedules[i].group
                    res += "\n\(schedules[i].calcTitle) "
                }
            }
            return res
        }
    }

    required convenience init?(map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        schedules <- (map["schedule"], SheduleTransform())
        dateCreatedAt <- (map["createdAt"], CustomDateTransform())
        dateModifiedAt <- (map["modifiedAt"], CustomDateTransform())
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    // Specify properties to ignore (Realm won't persist these)

    override static func ignoredProperties() -> [String] {
        return ["links"]
    }
}
