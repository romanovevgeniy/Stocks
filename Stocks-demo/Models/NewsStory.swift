//
//  NewsStory.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 08.11.2022.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
