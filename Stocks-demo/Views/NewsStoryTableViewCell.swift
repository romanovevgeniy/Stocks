//
//  NewsStoryTableViewCell.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 09.11.2022.
//

import SDWebImage
import UIKit

/// News story table view cell
final class NewsStoryTableViewCell: UITableViewCell {
    
    /// Cell identifier
    static let identifier = "NewsStoryTableViewCell"
    
    /// Ideal height of cell
    static let preferredHeight: CGFloat = 140
    
    /// Cell ViewModel
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }
    
    /// Source label
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    /// Headline label
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    /// Date label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    /// Image for story
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height / 1.3
        
        storyImageView.frame = CGRect(
            x: contentView.width-imageSize-10,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )
        
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(
            x: separatorInset.left,
            y: contentView.height - 40,
            width: availableWidth,
            height: 40
        )
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(
            x: separatorInset.left,
            y: 4,
            width: availableWidth,
            height: sourceLabel.height
        )
        
        headlineLabel.frame = CGRect(
            x: separatorInset.left,
            y: sourceLabel.bottom + 5,
            width: availableWidth,
            height: contentView.height - sourceLabel.bottom - dateLabel.height - 10
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func congigure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        
        storyImageView.sd_setImage(with: viewModel.imageUrl, completed: nil)
        
        // Manually set image
        // storyImageView.setImage(with: viewModel.imageUrl)
    }
}
