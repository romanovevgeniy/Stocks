//
//  ViewController.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 27.10.2022.
//

import UIKit

class WatchListViewController: UIViewController {
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTitleView()
    }
    
    // MARK: - Private
    
    private func setUpTitleView() {
        
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100
            )
        )
        
        let label = UILabel(
            frame: CGRect(
                x: 10,
                y: 0,
                width: titleView.width - 20,
                height: titleView.height
            )
        )
        label.text = "Акции"
        label.font = .systemFont(ofSize: 30, weight: .medium)
        titleView.addSubview(label)
        
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
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
        resultVC.update(with: ["GOOG"])
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: String) {
        // Представление о результатах данного выбора
        
    }
    
    
}

