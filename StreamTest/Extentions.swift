//
//  Extentions.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 02.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

extension Double {
    func toString(locale: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        numberFormatter.locale = Locale(identifier: locale)
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

public extension String {
    func toDate(format: String) -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZZ"
        return dateFormatter.date(from: self)!
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: ""))
    }
}

public extension Date {
    func toStringWith(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        //dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter.string(from: self)
    }
}
