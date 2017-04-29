//
//  TelephonyNetworkService.swift
//  Search
//
//  Created by Dmitry Rybochkin on 27.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import AVFoundation
import Contacts
import CoreAudio
import CoreMotion
import CoreTelephony
import Foundation
//import ReachabilitySwift
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork

class TelephonyNetworkService: NSObject, AVAudioSessionDelegate {
    public static let sharedManager = TelephonyNetworkService()
    let motionManager = CMMotionManager()

    private override init() {
        super.init()

        let ctTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        print("CTTelephonyNetworkInfo.currentRadioAccessTechnology:", ctTelephonyNetworkInfo.currentRadioAccessTechnology ?? "")
        if ctTelephonyNetworkInfo.subscriberCellularProvider != nil {
            print("CTTelephonyNetworkInfo.subscriberCellularProvider.allowsVOIP:", ctTelephonyNetworkInfo.subscriberCellularProvider?.allowsVOIP ?? "")
            print("CTTelephonyNetworkInfo.subscriberCellularProvider.carrierName:", ctTelephonyNetworkInfo.subscriberCellularProvider?.carrierName ?? "")
            print("CTTelephonyNetworkInfo.subscriberCellularProvider.isoCountryCode:", ctTelephonyNetworkInfo.subscriberCellularProvider?.isoCountryCode ?? "")
            print("CTTelephonyNetworkInfo.subscriberCellularProvider.mobileCountryCode:", ctTelephonyNetworkInfo.subscriberCellularProvider?.mobileCountryCode ?? "")
            print("CTTelephonyNetworkInfo.subscriberCellularProvider.mobileNetworkCode:", ctTelephonyNetworkInfo.subscriberCellularProvider?.mobileNetworkCode ?? "")
        }
        ctTelephonyNetworkInfo.subscriberCellularProviderDidUpdateNotifier = { (carrier) in
            print("carrier.allowsVOIP:", carrier.allowsVOIP)
            print("carrier.carrierName:", carrier.carrierName ?? "")
            print("carrier.isoCountryCode:", carrier.isoCountryCode ?? "")
            print("carrier.mobileCountryCode:", carrier.mobileCountryCode ?? "")
            print("carrier.mobileNetworkCode:", carrier.mobileNetworkCode ?? "")
        }

        let ctCallCenter = CTCallCenter()
        ctCallCenter.callEventHandler = { (ctCall) in
            print("ctCallCenter.callEventHandler: ", ctCall)
            if let calls = ctCallCenter.currentCalls {
                print("CTCallCenter.currentCalls", calls)
            }
        }
        if let calls = ctCallCenter.currentCalls {
            print("CTCallCenter.currentCalls: ", calls)
        } else {
            print("CTCallCenter.currentCalls: empty")
        }

        let ctCellularData = CTCellularData()
        print("CTCellularData.restrictedState: \(ctCellularData.restrictedState)")
        ctCellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            print("ctCellularData.cellularDataRestrictionDidUpdateNotifier: ", state) //CTCellularDataRestrictedState
        }

        let store = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if (status == .notDetermined) {
            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, _) -> Void in
                if (authorized) {
                    self.getContacts()
                }
            })
        } else if (status == .authorized) {
            getContacts()
        }
/*
        UIDevice.current.isBatteryMonitoringEnabled = true
        UIDevice.current.isProximityMonitoringEnabled = true

        print("batteryLevel: ", UIDevice.current.batteryLevel)
        print("batteryState: \(UIDevice.current.batteryState)")
        print("identifierForVendor: ", UIDevice.current.identifierForVendor ?? "")
        print("isBatteryMonitoringEnabled: ", UIDevice.current.isBatteryMonitoringEnabled)
        print("isProximityMonitoringEnabled: ", UIDevice.current.isProximityMonitoringEnabled)
        print("localizedModel: ", UIDevice.current.localizedModel)
        print("model: ", UIDevice.current.model)
        print("name: ", UIDevice.current.name)
        print("proximityState: ", UIDevice.current.proximityState)
        print("systemVersion: ", UIDevice.current.systemVersion)
        print("userInterfaceIdiom: \(UIDevice.current.userInterfaceIdiom)")
        print("isMultitaskingSupported: ", UIDevice.current.isMultitaskingSupported)
        print("isGeneratingDeviceOrientationNotifications: ", UIDevice.current.isGeneratingDeviceOrientationNotifications)
        print("orientation: \(UIDevice.current.orientation)")
*/
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryStateDidChange:")), name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)

        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 60 * 60 * 5
            motionManager.startMagnetometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                print("tMagnetometer data: ", data ?? "", " | error: ", error ?? "")
            })
        }

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 60 * 60 * 5
            motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                print("Gyro data: ", data ?? "", " | error: ", error ?? "")
            })
        }

        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 60 * 60 * 5
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                print("Accelerometer data: ", data ?? "", " | error: ", error ?? "")
            })
        }

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 60 * 60 * 5
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                print("DeviceMotion data: ", data ?? "", " | error: ", error ?? "")
            })
        }
        print("Sound outputVolume: ", AVAudioSession.sharedInstance().outputVolume)
        do {
            try AVAudioSession.sharedInstance().setActive(true, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
            AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        } catch {
            print("tracking audio error")
        }
        _ = connectedToNetwork()
    }

    deinit {
    }

    func batteryStateDidChange(notification: NSNotification) {
        //print("notification batteryState: \(UIDevice.current.batteryState)")
    }

    func batteryLevelDidChange(notification: NSNotification) {
        //print("notification batteryLevel: ", UIDevice.current.batteryLevel)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            print("Sound outputVolume tracking: ", AVAudioSession.sharedInstance().outputVolume)
        }
    }

    func connectedToNetwork() {
/*
        let reachability = Reachability()!

        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                print("Not reachable")
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }*/
    }

    func getContacts() {
        let contactStore = CNContactStore()

        var keys = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactNamePrefixKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPreviousFamilyNameKey as CNKeyDescriptor,
            CNContactNameSuffixKey as CNKeyDescriptor,
            CNContactNicknameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactDepartmentNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactPhoneticGivenNameKey as CNKeyDescriptor,
            CNContactPhoneticMiddleNameKey as CNKeyDescriptor,
            CNContactPhoneticFamilyNameKey as CNKeyDescriptor]

        if #available(iOS 10.0, *) {
            keys.append(contentsOf: [CNContactPhoneticOrganizationNameKey as CNKeyDescriptor,
                                     CNContactBirthdayKey as CNKeyDescriptor,
                                     CNContactNonGregorianBirthdayKey as CNKeyDescriptor,
                                     CNContactNoteKey as CNKeyDescriptor,
                                     CNContactImageDataKey as CNKeyDescriptor,
                                     CNContactThumbnailImageDataKey as CNKeyDescriptor,
                                     CNContactImageDataAvailableKey as CNKeyDescriptor,
                                     CNContactTypeKey as CNKeyDescriptor,
                                     CNContactPhoneNumbersKey as CNKeyDescriptor,
                                     CNContactEmailAddressesKey as CNKeyDescriptor,
                                     CNContactPostalAddressesKey as CNKeyDescriptor,
                                     CNContactDatesKey as CNKeyDescriptor,
                                     CNContactUrlAddressesKey as CNKeyDescriptor,
                                     CNContactRelationsKey as CNKeyDescriptor,
                                     CNContactSocialProfilesKey as CNKeyDescriptor,
                                     CNContactInstantMessageAddressesKey as CNKeyDescriptor])
        }
        let request = CNContactFetchRequest(keysToFetch: keys)
        do {

            try contactStore.enumerateContacts(with: request) { contact, _ in
                print("contact: ", contact)
            }
        } catch let error {
            print(error.localizedDescription)
        }

        _ = getNetworkInterfaces()

    }

    func getNetworkInterfaces() -> Bool {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            print("this must be a simulator, no interfaces found")
            return false
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            print("System error: did not come back as array of Strings")
            return false
        }
        for interface in swiftInterfaces {
            print("Looking up SSID info for \(interface)") // en0
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                print("System error: \(interface) has no information")
                return false
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                print("System error: interface information is not a string-keyed dictionary")
                return false
            }
            for d in SSIDDict.keys {
                print("\(d): \(SSIDDict[d]!)")
                if d == "SSIDDATA" {
                    if let value = SSIDDict[d] as? Data, let str = String(data: value, encoding: .utf8) {
                        print(str)
                    }
                }

            }
        }
        return true
    }
}
