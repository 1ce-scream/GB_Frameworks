//
//  LoginViewModel.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 23.05.2022.
//

import Foundation
import RealmSwift

final class LoginViewModel {
    
    func checkUserData(login: String, password: String) -> Bool {
        let realmUser = try? RealmService.loadByKey(typeOf: RealmUser.self,
                                                    primaryKey: login)
        guard
            let user = realmUser,
            password == user.password
        else {
            return false
        }
        return true
    }
    
    /*
     The stupid logic of next code is due to the terms of reference
     */
    
    func registerUser(login: String, password: String) -> Bool {
        let realmUser = try? RealmService.loadByKey(typeOf: RealmUser.self,
                                                    primaryKey: login)
        
        if let user = realmUser {
            try? RealmService.updatePassword(user: user, password: password)
            return true
        } else {
            let newUser = RealmUser()
            newUser.login = login
            newUser.password = password
            try? RealmService.save(items: [newUser])
            return false
        }
    }
}
