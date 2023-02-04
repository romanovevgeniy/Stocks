//
//  NewsHeaderView.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 06.11.2022.
//

import UIKit

/// Delegate to notify of header events
protocol NewsHeaderViewDelegate: AnyObject {
    
    /// Notify user tapped header button
    /// - Parameter headerView: Ref of header view
    func NewsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

/// Table view header for news
final class NewsHeaderView: UITableViewHeaderFooterView {
    /// Header idetifier
    static let identifier = "NewsHeaderView"
    
    /// Ideal height of header
    static let preferredHeight: CGFloat = 80
    
    /// Delegate instance for events
    weak var delegate: NewsHeaderViewDelegate?
    
    /// ViewModel for header view
    struct ViewModeL {
        let title: String
        let shouldShowAndButton: Bool
    }
    
    //MARK: - Private
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ в избранное", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(button, label)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width-28, height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 16,
            y: (contentView.height - button.height) / 2,
            width: button.width + 9,
            height: button.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    /// Handle button tap
    @objc func didTapButton() {
        // Call delegate
        delegate?.NewsHeaderViewDidTapAddButton(self)
    }
    
    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel: ViewModeL) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAndButton
    }
}
