//
//  EnvironmentService.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 29.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import CoreMotion
import Foundation
import UIKit

enum EnvironmentServiceTypes: String {
    case
    notDefine       = "NotDefine",
    accelerometr    = "Accelerometr",
    device          = "Device",
    battery         = "Battery"
}

enum EnvironmentErrorCodes: Int {
    case
    notAvailable       = -1,
    differentIntervals = -2,
    valueIsNil         = -3
}

typealias EnvironmentHandler<T> = (T?, Error?) -> Void

class EnvironmentTrackingRequest<T>: Equatable {
    var handler: EnvironmentHandler<T>?
    var isActive: Bool = false

    init(handler: EnvironmentHandler<T>?) {
        self.handler = handler
    }

    func callback(value: T?, error: Error?, force: Bool = true) {
        if let handler = handler, (force) || (isActive) {
            handler(value, error)
        }
    }

    static func == (lhs: EnvironmentTrackingRequest<T>, rhs: EnvironmentTrackingRequest<T>) -> Bool {
        return lhs === rhs
    }

}

protocol EnvironmentServiceProtocol {
    associatedtype ManagerClass

    var manager: ManagerClass { get set }

    func startTrackingWith(interval: TimeInterval) -> Self
    func stopTracking()
}

class EnvironmentService<T>: NSObject {
    var timeInterval: TimeInterval?
    var environmentType: EnvironmentServiceTypes = .notDefine
    var requests: [EnvironmentTrackingRequest<T>] = []
    internal(set) var isActive: Bool = false
    internal var lastValue: T?
    internal var lastError: Error?

    override init() {
        super.init()
    }

    init(environmentType: EnvironmentServiceTypes, timeInterval: TimeInterval? = nil) {
        self.environmentType = environmentType
        self.timeInterval = timeInterval
    }

    func removeRequest(_ request: EnvironmentTrackingRequest<T>) {
        if let index = requests.index(of: request) {
            request.isActive = false
            requests.remove(at: index)
        }
    }

    func addRequestWith(active: Bool = true, callback: EnvironmentHandler<T>? = nil) -> EnvironmentTrackingRequest<T> {
        let request = EnvironmentTrackingRequest(handler: callback)
        request.isActive = active
        requests.append(request)
        if isActive {
            request.callback(value: lastValue, error: lastError)
        }
        return request
    }

    func startAllRequests() {
        for request in requests {
            request.isActive = true
        }
    }

    func stopAllRequests() {
        for request in requests {
            request.isActive = false
        }
    }

    func removeAllRequests() {
        stopAllRequests()
        requests.removeAll()
    }

    func callbackAllRequests(value: T? = nil, error: Error? = nil, force: Bool = false) {
        lastValue = value
        lastError = error
        for request in requests {
            request.callback(value: value, error: error, force: force)
        }
    }
}

class AccelerometerData {
    var accelerationX: Double
    var accelerationY: Double
    var accelerationZ: Double

    init(cmAccelerometerData: CMAccelerometerData) {
        accelerationX = cmAccelerometerData.acceleration.x
        accelerationY = cmAccelerometerData.acceleration.y
        accelerationZ = cmAccelerometerData.acceleration.z
    }
}

class MotionService: EnvironmentService<AccelerometerData>, EnvironmentServiceProtocol {
    typealias ManagerClass = CMMotionManager

    public static let sharedManager = MotionService()
    internal var manager: ManagerClass

    private override init() {
        manager = CMMotionManager()
        super.init(environmentType: .accelerometr)
    }

    func startTrackingWith(interval: TimeInterval) -> Self {
        if (manager.isAccelerometerAvailable) && (!manager.isAccelerometerActive) {
            timeInterval = interval
            if let timeInterval = timeInterval {
                manager.accelerometerUpdateInterval = timeInterval
            }
            isActive = true
            startAllRequests()
            manager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                if let data = data {
                    self.callbackAllRequests(value: AccelerometerData(cmAccelerometerData: data), error: error)
                } else {
                    let error = NSError(domain:"\(String(describing: self))",
                        code: EnvironmentErrorCodes.valueIsNil.rawValue,
                        userInfo:nil)
                    self.callbackAllRequests(value: self.lastValue, error: error)
                }
            })
            callbackAllRequests(value: lastValue, error: lastError)
        } else if (manager.isAccelerometerActive) && (timeInterval != interval) {
            let error = NSError(domain:"\(String(describing: self))",
                                code: EnvironmentErrorCodes.differentIntervals.rawValue,
                                userInfo:nil)
            self.callbackAllRequests(value: lastValue, error: error)
        } else if !manager.isAccelerometerAvailable {
            let error = NSError(domain:"\(String(describing: self))",
                                code: EnvironmentErrorCodes.notAvailable.rawValue,
                                userInfo:nil)
            self.callbackAllRequests(value: lastValue, error: error)
        }
        return self
    }

    func stopTracking() {
        if manager.isAccelerometerActive {
            manager.stopAccelerometerUpdates()
        }
        isActive = false
    }
}

class DeviceData {
    var identifierForVendor: UUID?
    var isBatteryMonitoringEnabled: Bool
    var isProximityMonitoringEnabled: Bool
    var localizedModel: String
    var model: String
    var name: String
    var proximityState: Bool
    var systemVersion: String
    var userInterfaceIdiom: UIUserInterfaceIdiom
    var isMultitaskingSupported: Bool
    var isDeviceOrientationNotifications: Bool
    var orientation: UIDeviceOrientation

    init(device: UIDevice) {
        identifierForVendor = device.identifierForVendor
        isBatteryMonitoringEnabled = device.isBatteryMonitoringEnabled
        isProximityMonitoringEnabled = device.isProximityMonitoringEnabled
        localizedModel = device.localizedModel
        model = device.model
        name = device.name
        proximityState = device.proximityState
        systemVersion = device.systemVersion
        userInterfaceIdiom = device.userInterfaceIdiom
        isMultitaskingSupported = device.isMultitaskingSupported
        isDeviceOrientationNotifications = device.isGeneratingDeviceOrientationNotifications
        orientation = device.orientation
    }
}

class DeviceService: EnvironmentService<DeviceData>, EnvironmentServiceProtocol {
    typealias ManagerClass = UIDevice

    public static let sharedManager = DeviceService()
    internal var manager: ManagerClass
    private var timer: Timer?

    private override init() {
        manager = UIDevice.current

        super.init(environmentType: .device)

        lastValue = DeviceData(device: UIDevice.current)
        lastError = nil
    }

    internal func onTimer(_: Timer) {
        self.callbackAllRequests(value: DeviceData(device: UIDevice.current), error: nil)
    }

    internal func startNotifier(interval: TimeInterval) {
        timeInterval = interval
        if #available(iOS 10.0, *) {
            timer = Timer(timeInterval: interval, repeats: true, block: onTimer)
        } else {
            timer = Timer(timeInterval: interval, target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: true)
        }
        callbackAllRequests(value: lastValue, error: lastError)
    }

    func startTrackingWith(interval: TimeInterval) -> Self {
        if (timer == nil) {
            startNotifier(interval: interval)
        } else if let timer = timer, !timer.isValid, timer.timeInterval != interval {
            startNotifier(interval: interval)
        } else if timer?.timeInterval != interval {
            let error = NSError(domain:"\(String(describing: self))",
                                code: EnvironmentErrorCodes.differentIntervals.rawValue,
                                userInfo:nil)
            callbackAllRequests(value: lastValue, error: error)
        }

        if !isActive, let timer = timer {
            isActive = true
            startAllRequests()
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            timer.fire()
        }
        return self
    }

    func stopTracking() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
        isActive = false
    }
}

class BatteryData {
    var state: UIDeviceBatteryState
    var level: Float

    init(state: UIDeviceBatteryState, level: Float) {
        self.state = state
        self.level = level
    }
}

class BatteryService: EnvironmentService<BatteryData>, EnvironmentServiceProtocol {
    typealias ManagerClass = UIDevice

    public static let sharedManager = BatteryService()
    internal var manager: ManagerClass

    private override init() {
        manager = UIDevice.current

        UIDevice.current.isBatteryMonitoringEnabled = true

        super.init(environmentType: .battery)

        lastValue = BatteryData(state: manager.batteryState, level: manager.batteryLevel)
        lastError = nil
    }

    func batteryStateDidChange(notification: NSNotification) {
        callbackAllRequests(value: BatteryData(state: manager.batteryState, level: manager.batteryLevel), error: nil)
    }

    func startTrackingWith(interval: TimeInterval = 0) -> Self {
        if (!isActive) {
            NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
            isActive = true
            callbackAllRequests(value: lastValue, error: lastError)
        }

        return self
    }

    func stopTracking() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        isActive = false
    }
}
