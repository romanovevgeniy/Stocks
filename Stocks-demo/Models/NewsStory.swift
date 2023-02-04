//
//  NewsStory.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 08.11.2022.
//

import Foundation

/// Represent news story
struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
