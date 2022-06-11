//
//  ArticleTableViewCell.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import UIKit

final class ArticleListItemViewCell: UITableViewCell {
    typealias DidToggleFavoriteHandler = (() -> Void)
    
    static let identifier = "ArticleListItemViewCell"
    static let nib = "ArticleListItemViewCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var didToggleFavoriteHandler: DidToggleFavoriteHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        configureFavoriteImageView()
    }
    
    private func configureFavoriteImageView () {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didToggleFavorite))
        favoriteImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
        sourceLabel.text = ""
        descriptionLabel.text = ""
    }
    
    func update(for viewModel: ArticleListItemViewModel) {
        titleLabel.text = viewModel.article.title
        authorLabel.text = viewModel.article.author
        sourceLabel.text = viewModel.article.soruce
        descriptionLabel.text = viewModel.article.content
        
        updateFavoirteImageView(isFavorite: viewModel.article.isFavorite)
        
        viewModel.loadImage { [weak self] data in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data)
            else {
                return
            }
            
            self.posterImageView.image = image
        }
        
        didToggleFavoriteHandler = { [weak self] in
            guard let self = self else { return }

            viewModel.toggleFavorite { [weak self] result in
                guard let self = self,
                      case let .success(article) = result
                else {
                    return
                }
                
                self.updateFavoirteImageView(isFavorite: article.isFavorite)
            }
        }
    }
    
    private func updateFavoirteImageView(isFavorite: Bool) {
        favoriteImageView.image = UIImage(systemName: isFavorite ? "star.fill" : "star")
    }
    
    @objc
    private func didToggleFavorite() {
        didToggleFavoriteHandler?()
    }
}
