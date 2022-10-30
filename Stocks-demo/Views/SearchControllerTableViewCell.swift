//
//  SearchControllerTableViewCell.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 30.10.2022.
//

import UIKit

class SearchControllerTableViewCell: UITableViewCell {
    static let identifier = "SearchControllerTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
