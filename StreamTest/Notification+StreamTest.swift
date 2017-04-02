//
//  Notification+StreamTest.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 25.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static var StreamTestDataWillLoad: NSNotification.Name = NSNotification.Name("StreamTestDataWillLoad")
    public static var StreamTestDataDidLoad: NSNotification.Name = NSNotification.Name("StreamTestDataDidLoad")
    public static var StreamTestDataLoad: NSNotification.Name = NSNotification.Name("StreamTestDataLoad")
    public static var StreamTestLocationUpdated: NSNotification.Name = NSNotification.Name("StreamTestLocationUpdated")

}
