//
//  ViewController.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 27.10.2022.
//

import UIKit
import FloatingPanel

/// VC to render user watch list
final class WatchListViewController: UIViewController {
    
    /// Timer to optimize searching
    private var searchTimer: Timer?
    
    /// Floating news panel
    private var panel: FloatingPanelController?
    
    /// Width to track change label geometry
    static var maxChangeWidth: CGFloat = 0
    
    /// Model
    private var watchListMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    /// Main view to render watch list
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(
            WatchListTableViewCell.self,
            forCellReuseIdentifier: WatchListTableViewCell.identifier
        )
        
        return table
    }()
    
    /// Observer to watch list updates
    private var odserver: NSObjectProtocol?
    
    //MARK: - Lifecycle
    
    /// Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fetchUpWatchListData()
        setUpFloatingPanel()
        setUpTitleView()
        setUpObserver()
    }
    
    /// Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    /// Sets up observer for watch list updates
    private func setUpObserver() {
        odserver = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main
            ) { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchUpWatchListData()
            }
    }
    
    /// Fetch watch list models
    private func fetchUpWatchListData() {
        let symbols = PersistenceManager.shared.watchList
        
        createPlaceholderViewModels()
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchListMap[symbol] == nil {
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
    
    private func createPlaceholderViewModels() {
        let symbols = PersistenceManager.shared.watchList
        symbols.forEach { item in
            viewModels.append(
                .init(
                    symbol: item,
                    companyName: UserDefaults.standard.string(forKey: item) ?? "Company",
                    price: "0.00",
                    changeColor: .systemGreen,
                    changePercentage: "0.00",
                    chartViewModel: .init(
                        data: [],
                        showLegend: false,
                        showAxis: false,
                        fillColor: .clear
                    )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
        tableView.reloadData()
    }
    
    /// Creates view models from models
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchListMap {
            let changePercentage = candleSticks.getPercentage()
            
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Компания",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .percentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                    )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: {$0.symbol < $1.symbol})
    }
    
    /// Gets latest closing price
    /// - Parameter data: Collection of data
    /// - Returns: String
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return .formatted(number: closingPrice)
    }
    
    /// Sets up table view
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Sets up floating news panels
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }
    
    /// Set up custom title view
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
    
    /// Set up search and results controller
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchBar.placeholder = "Поиск"
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

// MARK: - UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
    
    /// Update search on key tap
    /// - Parameter searchController: Ref of the search controller
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
        let resultVC = searchController.searchResultsController as? SearchResultsViewController,
        !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        // Reset timer
        searchTimer?.invalidate()
        // Optimize: number of requests
        // Create new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
        // Call api from search
            
            APIManager.shared.search(query: query) { result in
                switch result {
                    case .success(let response):
        // Update result controller
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

// MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController: SearchResultsViewControllerDelegate {
    
    /// Notify of search result selection
    /// - Parameter searchResult: Search result that was selected
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = StocksDetailViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    
    /// Gets floating panel state change
    /// - Parameter fpc: Ref of controller
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier,
            for: indexPath
        ) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // Update state
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            
            // Update ViewModel
            viewModels.remove(at: indexPath.row)
            
            // Delete rows
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        
        let viewModel = viewModels[indexPath.row]
        let vc = StocksDetailViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchListMap[viewModel.symbol] ?? []
        )
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
}

// MARK: - WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    
    /// Notify delegate of change label width
    func didUpdateMaxWidth() {
        // Optimize : Only refresh rows prior to the current row that changes the max width
        tableView.reloadData()
    }
}

