//
//  StockDetailHeaderView.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 02.02.2023.
//

import UIKit

class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var metricViewModels: [MetricsCollectionViewCell.ViewModel] = []
    
    private let chartView = StockChartView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            MetricsCollectionViewCell.self,
            forCellWithReuseIdentifier: MetricsCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .secondarySystemBackground
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height - 100)
        collectionView.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
    }
    
    func configure(
        chartViewModel: StockChartView.ViewModel,
        metricViewModels: [MetricsCollectionViewCell.ViewModel]
    ) {
        chartView.configure(with: chartViewModel)
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
    
    // MARK - CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricsCollectionViewCell.identifier,
            for: indexPath
        ) as? MetricsCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
}
