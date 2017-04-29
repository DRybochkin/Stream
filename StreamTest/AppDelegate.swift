//
//  AppDelegate.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 25.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

/*
 Общее описание
 
 Необходимо получить с сервера и отобразить на экране телефона в табличном представлении информацию о точках Космос банка.
 
 В таблице необходимо выводить следующие поля:
 •	Название точки
 •	Адрес
 •	Время работы
 •	Расстояние (если пользователь предоставил доступ к службам геолокации)
 
 Если у кандидата останется время, то в качестве дополнительного задания необходимо добавить кэширование данных.
 
 Формат запроса
 
 Url: http://gymn652.ru/tmp/unicorn.txt-2.json
 Response content-type: application/json
 В ответе содержится информация о точках Космос банка
 
 Требования и ограничения
 
 •	iOS 8+
 •	Objective-C/Swift 3.0
 •	Только iPhone (без iPad)
 •	Можно использовать любые сторонние библиотеки и компоненты
 •	Особые требования к дизайну не предъявляются (важна лишь возможность прочитать информацию)
 
 
 */

import UIKit

/*Периодичность проверки обновлений*/
let timeItervalCheck = 1000

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var timer: Timer?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //_ = DataManager.sharedManager

        //_ = LocationService.sharedManager

        _ = MotionService.sharedManager.addRequestWith(callback: { (data, error) in
            print("1 ==> data: \(String(describing: data)) | error \(String(describing: error))")
        })

        _ = MotionService.sharedManager.addRequestWith(callback: { (data, error) in
            print("2 ==> data: \(String(describing: data)) | error \(String(describing: error))")
        })

        _ = MotionService.sharedManager.startTrackingWith(interval: 1)

        _ = DeviceService.sharedManager.addRequestWith(callback: { (data, error) in
            print("3 ==> data: \(String(describing: data)) | error \(String(describing: error))")
        })

        _ = DeviceService.sharedManager.startTrackingWith(interval: 100)

        _ = BatteryService.sharedManager.addRequestWith(callback: { (data, error) in
            print("4 ==> data: \(String(describing: data)) | error \(String(describing: error))")
        })

        _ = BatteryService.sharedManager.startTrackingWith()

        /*
        if #available(iOS 10.0, *) {
            timer = Timer(timeInterval: TimeInterval(timeItervalCheck), repeats: true, block: onTimer)
        } else {
            // Fallback on earlier versions
            timer = Timer(timeInterval: TimeInterval(timeItervalCheck), target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: true)

        }

        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)

        timer?.fire()
*/
        return true
    }

    func onTimer(_: Timer) {
        print("send timer load data")
        NotificationCenter.default.post(name: Notification.Name.StreamTestDataLoad, object: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
