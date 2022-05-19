//
//  RealmService.swift
//  VKApp_TalalayVV
//
//  Created by Vitaliy Talalay on 17.10.2021.
//

import Foundation
import RealmSwift

public extension Realm {
     func safeWrite(_ block: () throws -> Void) throws {
         if isInWriteTransaction {
             try block()
         } else {
             try write(block)
         }
     }
 }

class RealmService {
    
    static let deleteIfMigration = Realm.Configuration(
        deleteRealmIfMigrationNeeded: true)
    
    static func save<T:Object>(
        items: [T],
        configuration: Realm.Configuration = deleteIfMigration,
        update: Realm.UpdatePolicy = .modified
    ) throws {
        let realm = try Realm(configuration: configuration)
        print(configuration.fileURL ?? "")
        try realm.safeWrite {
            realm.add(items, update: update)
        }
    }
    
    static func load<T:Object>(typeOf: T.Type) throws -> Results<T> {
        let realm = try Realm()
        print(realm.configuration.fileURL ?? "")
        return realm.objects(T.self)
    }
    
    static func delete<T:Object>(object: Results<T>) throws {
        let realm = try Realm()
        try realm.safeWrite{
            realm.delete(object)
        }
    }
    
    static func deleteAll() throws {
        let realm = try Realm()
        try realm.safeWrite {
            realm.deleteAll()
        }
    }
}

