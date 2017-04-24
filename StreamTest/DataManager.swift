//
//  DataManager.swift
//  StreamTest
//
//  Created by Dmitry Rybochkin on 18/01/2017.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation
import RealmSwift

public class DataManager {
    public let realm: Realm

    public static let sharedManager = DataManager()

    private init() {
        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { _, _ in
            }
        )
        Realm.Configuration.defaultConfiguration = config

        //disabled vendor reccomendation
        realm = try! Realm() // swiftlint:disable:this force_try

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadFilesDataFromNetwork),
                                               name: NSNotification.Name.StreamTestDataLoad, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func add(_ item: Object) -> Bool {
        do {
            try realm.write {
                realm.add(item, update: true)
            }
            return true
        } catch {
            return false
        }
    }

    func add(_ items: [Object]) -> Bool {
        do {
            try realm.write {
                for item in items {
                    realm.add(item, update: true)
                }
            }
            return true
        } catch {
            return false
        }
    }

    func getItem<T: Object>(_:T.Type, itemId: String) -> T? {
        return realm.object(ofType:T.self, forPrimaryKey:"\(itemId)")
    }

    func getItem<T: Object>(_:T.Type, itemId: Int) -> T? {
        return realm.object(ofType:T.self, forPrimaryKey: itemId)
    }

    func getItems<T: Object>(_:T.Type) -> [T] {
        return Array(realm.objects(T.self))
    }

    func delete<T: Object>(objects ofType: T.Type, _ predicate: NSPredicate) {
        try? realm.write {
            realm.delete(realm.objects(ofType).filter(predicate))
        }
    }

    func delete<T: Object>(objects: List<T>) {
        try? realm.write {
            realm.delete(objects)
        }
    }

    func delete<T: Object>(object: T) {
        try? realm.write {
            realm.delete(object)
        }
    }

    func delete<T: Object>(objects: List<T>, _ predicate: NSPredicate) {
        try? realm.write {
            realm.delete(objects.filter(predicate))
        }
    }

    @objc
    func loadFilesDataFromNetwork(forceUpdate: Bool = true) {
        print("start loading forceUpdate = \(forceUpdate)")
        NotificationCenter.default.post(name: Notification.Name.StreamTestDataWillLoad, object: nil)
        let fileIds = ["2"]
        let fileLoadGroup = DispatchGroup()
        print("start load files")
        var loadedItems: [PlaceModel] = []
        for fileId in fileIds {
            fileLoadGroup.enter()
            _ = ServiceClient.getPlacesRequest(fileId).send({ succeed, result, error in
                if let places: [PlaceModel] = result?.serialize(PlaceModel.self, fromItem:"items") {
                    loadedItems.append(contentsOf: places)
                } else {
                    print("\(succeed), \(String(describing: result)), \(String(describing: error))")
                }
                fileLoadGroup.leave()
            })
        }

        fileLoadGroup.notify(queue: .main, execute: {
            print("files loaded")
            print("start update local database")
            var itemsToUpdate: [String: PlaceModel] = [:]
            let locationsToDelete: List<PlaceLocationModel> = List<PlaceLocationModel>()
            var schedulesToDelete: [List<ScheduleModel>] = []
            for item in loadedItems {
                if itemsToUpdate.keys.contains(item.id) {
                    if let oldItem = itemsToUpdate[item.id] {
                        if item.modifiedAt! > oldItem.modifiedAt! {
                            itemsToUpdate[item.id] = item
                        }
                    }
                } else {
                    if let oldItem = self.getItem(PlaceModel.self, itemId: item.id) {
                        if (forceUpdate) || (item.modifiedAt == nil) || (oldItem.modifiedAt == nil) || (item.modifiedAt! > oldItem.modifiedAt!) {
                            if let loc = oldItem.location {
                                locationsToDelete.append(loc)
                            }
                            if !oldItem.schedule.isEmpty {
                                schedulesToDelete.append(oldItem.schedule)
                            }
                            itemsToUpdate[item.id] = item
                        }
                    } else {
                        itemsToUpdate[item.id] = item
                    }
                }
            }
            print("local database has to update \(itemsToUpdate.keys.count) items")

            try? self.realm.write {
                for location in locationsToDelete {
                    self.realm.delete(location)
                }
                for shedule in schedulesToDelete {
                    self.realm.delete(shedule)
                }
                for item in itemsToUpdate {
                    self.realm.add(item.value, update: true)
                }
            }

            print("local database updated")
            NotificationCenter.default.post(name: Notification.Name.StreamTestDataDidLoad,
                                            object: !itemsToUpdate.keys.isEmpty)
        })
    }
}
