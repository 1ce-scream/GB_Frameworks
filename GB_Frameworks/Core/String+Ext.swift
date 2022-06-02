//
//  String+Ext.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 31.05.2022.
//

import Foundation
import CryptoKit

extension String {
    func SHA256Hash() -> String {
        guard #available(iOS 13, *) else { return "unavailable iOS version"}
        
        if let stringData = self.data(using: String.Encoding.utf8) {
            let hashedString = SHA256.hash(data: stringData)
            let hash = hashedString.compactMap { String(format: "%02x", $0) }.joined()
            return hash
        } else {
            return "smth went wrong with SHA"
        }
    }
}
