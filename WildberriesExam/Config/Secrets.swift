//
//  Secrets.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 08.09.2026.
//

import Foundation

enum Secrets {
    static var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("Api Key not found or couldn't be parsed. Check Secrets.xcconfig")
        }
        
        return key
    }
}
