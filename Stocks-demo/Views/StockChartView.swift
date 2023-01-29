//
//  StockChartView.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 28.01.2023.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // Сброс диаграммы
    func reset() {
        
    }
    
    func configure(with viewModel: ViewModel) {
        
    }
}
