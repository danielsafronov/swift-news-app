//
//  ArticleListItemViewModel.swift
//  news
//
//  Created by Daniel Safronov on 09.06.2022.
//

import Foundation

final class ArticleListItemViewModel {
    private (set) var article: Article
    var image: Data? = nil
    
    let getArticleImageUseCase: GetArticleImageUseCase
    let addArticleToFavoriteUseCase: AddArticleToFavoriteUseCase
    let removeArticleFromFavoriteUseCase: RemoveArticleFromFavoriteUseCase
    
    private var loadImageWorkItem: DispatchWorkItem? {
        willSet {
            if let loadImageWorkItem = loadImageWorkItem, !loadImageWorkItem.isCancelled {
                loadImageWorkItem.cancel()
            }
        }
    }
    
    private var toggleFavoriteWorkItem: DispatchWorkItem? {
        willSet {
            if let toggleFavoriteWorkItem = toggleFavoriteWorkItem, !toggleFavoriteWorkItem.isCancelled {
                toggleFavoriteWorkItem.cancel()
            }
        }
    }
    
    init(article: Article, getArticleImageUseCase: GetArticleImageUseCase, addToFavoriteUseCase: AddArticleToFavoriteUseCase, removeArticleFromFavoriteUseCase: RemoveArticleFromFavoriteUseCase) {
        self.article = article
        self.getArticleImageUseCase = getArticleImageUseCase
        self.addArticleToFavoriteUseCase = addToFavoriteUseCase
        self.removeArticleFromFavoriteUseCase = removeArticleFromFavoriteUseCase
    }
    
    func loadImage(resultQueue: DispatchQueue = .main, completionHandler: @escaping (Data?) -> Void) {
        if let image = image {
            resultQueue.async { completionHandler(image) }
            return
        }
        
        loadImageWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  let imageUrl = self.article.imageUrl
            else {
                return
            }
            
            self.getArticleImageUseCase.invoke(url: imageUrl) { [weak self] result in
                guard let self = self,
                      let loadImageWorkItem = self.loadImageWorkItem,
                      !loadImageWorkItem.isCancelled
                else {
                    return
                }
                
                switch result {
                case .success(let data):
                    self.image = data
                    
                    resultQueue.async { [weak self] in
                        guard let self = self else { return }
                        completionHandler(self.image)
                    }
                    
                case .failure(_):
                    resultQueue.async { completionHandler(nil) }
                }
                
                self.loadImageWorkItem = nil
            }
        }
        
        if let loadImageWorkItem = loadImageWorkItem {
            DispatchQueue.global().async(execute: loadImageWorkItem)
        }
    }
    
    func toggleFavorite(resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Article, Error>) -> Void) {
        toggleFavoriteWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let useCase = self.resolveToggleFavoriteUseCase(byArticle: self.article)
            useCase.invoke(article: self.article) { [weak self] result in
                guard let self = self,
                      let toggleFavoriteWorkItem = self.toggleFavoriteWorkItem,
                      !toggleFavoriteWorkItem.isCancelled
                else {
                    return
                }
                
                switch result {
                case .success(_):
                    self.article.isFavorite = !self.article.isFavorite
                    
                    resultQueue.async { [weak self] in
                        guard let self = self else { return }
                        completionHandler(.success(self.article))
                    }
                    
                case .failure(let error):
                    resultQueue.async { completionHandler(.failure(error)) }
                }
                
                self.toggleFavoriteWorkItem = nil
            }
        }
        
        if let toggleFavoriteWorkItem = toggleFavoriteWorkItem {
            DispatchQueue.global().async(execute: toggleFavoriteWorkItem)
        }
    }
    
    private func resolveToggleFavoriteUseCase(byArticle: Article) -> ToggleFavoriteUseCase {
        article.isFavorite ? removeArticleFromFavoriteUseCase : addArticleToFavoriteUseCase
    }
}
