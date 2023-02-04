//
//  Stocks_demoTests.swift
//  Stocks-demoTests
//
//  Created by Евгений Романов on 04.02.2023.
//

@testable import Stocks_demo

import XCTest

final class Stocks_demoTests: XCTestCase {
    func testSomething() {
        let number = 1
        let string = "1"
        
        XCTAssertEqual(number, Int(string), "Numbers do not match")
    }
    
    func testCandleStickDataConversion() {
        let doubles: [Double] = Array(repeating: 12.2, count: 10)
        var timestamps: [TimeInterval] = []
        
        for x in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            timestamps.append(interval)
        }
        timestamps.shuffle()
        
        let marketData = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            status: "success",
            timestamps: timestamps
        )
        
        let candleSticks = marketData.candleSticks
        
        XCTAssertEqual(candleSticks.count, marketData.open.count)
        XCTAssertEqual(candleSticks.count, marketData.close.count)
        XCTAssertEqual(candleSticks.count, marketData.low.count)
        XCTAssertEqual(candleSticks.count, marketData.high.count)
        
        // Verify sort
        let dates = candleSticks.map { $0.date }
        for x in 0..<dates.count-1 {
            let current = dates[x]
            let next = dates[x+1]
            XCTAssertTrue(current > next, "\(current) date should be greater than \(next) date")
        }
    }
}
