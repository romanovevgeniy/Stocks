//
//  ViewController.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 27.10.2022.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    private var panel: FloatingPanelController?
    
    /// Models
    private var watchListMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        
        return table
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fetchUpWatchListData()
        setUpFloatingPanel()
        setUpTitleView()
    }
    
    // MARK: - Private
    
    private func fetchUpWatchListData() {
        let symbols = PersistenceManager.shared.watchList
        let group = DispatchGroup()
        for symbol in symbols {
            group.enter()
            
            APIManager.shared.marketData(for: symbol) { [weak self] result in
//                defer {
//                    group.leave()
//                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchListMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = getChangePercentage(
                symbol: symbol,
                data: candleSticks
            )
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Компания",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: "\(changePercentage)"
                )
            )
        }
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
            let priorClose = data.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close else {
            return 0
        }
        let diff = priorClose/latestClose
        return diff
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return "\(closingPrice)"
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
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
        searchVC.searchBar.placeholder = "Поиск"
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
        
        // сброс таймера
        searchTimer?.invalidate()
        // оптимизация по количеству запросов
        // создание нового таймера
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
        // вызов API для поиска
            
            APIManager.shared.search(query: query) { result in
                switch result {
                    case .success(let response):
        // обновление контроллера результатов
                        DispatchQueue.main.async {
                            resultVC.update(with: response.result)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            resultVC.update(with: [])
                        }
                        print(error)
                }
            }
        })
        
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StocksDetailViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchListMap.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // открытие деталей выбора
    }
}

