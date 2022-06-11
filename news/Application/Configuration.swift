//
//  Configuration.swift
//  news
//
//  Created by Daniel Safronov on 11.06.2022.
//

import Foundation

struct Configuration {
    private static func object(byKey key: String) -> Any? {
        Bundle.main.object(forInfoDictionaryKey: key)
    }
}

extension Configuration {
    static func string(byKey key: String) -> String? {
        guard let object = object(byKey: key),
              let value = object as? String
        else {
            return nil
        }
        
        return value
    }
}

extension Configuration {
    static func requiredString(byKey key: String) -> String {
        string(byKey: key)!
    }
}
