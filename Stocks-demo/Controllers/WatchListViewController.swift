//
//  ViewController.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 27.10.2022.
//

import UIKit

class WatchListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
    }
    
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
        let resultVC = searchController.searchResultsController as? SearchResultsViewController,
        !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // оптимизация по количеству запросов
        
        // вызов API для поиска
        
        // обновление контроллера результатов
        
    }
}

