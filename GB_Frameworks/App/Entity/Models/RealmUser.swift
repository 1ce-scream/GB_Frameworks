//
//  RealmUser.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 23.05.2022.
//

import Foundation
import RealmSwift

class RealmUser: Object {
    @Persisted(indexed: true) var userID: String = UUID().uuidString
    @Persisted(primaryKey: true) var login: String
    @Persisted var password: String
}
