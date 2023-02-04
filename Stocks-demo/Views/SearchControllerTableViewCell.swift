//
//  SearchControllerTableViewCell.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 30.10.2022.
//

import UIKit

/// Table view cel for search result
final class SearchControllerTableViewCell: UITableViewCell {
    /// Identifier for cell
    static let identifier = "SearchControllerTableViewCell"
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
