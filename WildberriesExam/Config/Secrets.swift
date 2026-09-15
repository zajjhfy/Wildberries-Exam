//
//  Secrets.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 08.09.2026.
//

import Foundation
import NetworkPackage

enum Secrets {
    static var apiKey: String {
        get throws {
            guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
                throw NetworkError.missingAPIKey
            }
            // Validate the same input as every NetworkPackage consumer.
            _ = try APIConfiguration(apiKey: key)
            return key
        }
    }
}
