//
//  DefaultFeedRepository.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

struct DefaultArticleRepository: ArticleRepository {
    let apiDataSource: ArticleAPIDataSource
    let cacheDataSource: ArticleCacheDataSource
    
    func articles(onPage page: Int, count pageSize: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void) {
        apiDataSource.articles(onPage: page, count: pageSize, sources: sources, where: query) { result in
            switch result {
            case .success(let remoteArticles):
                let uris = remoteArticles.map { $0.url }
                cacheDataSource.articles(byURI: uris) { result in
                    switch result {
                    case .success(let cachedArticles):
                        let articles = remoteArticles.map { article in
                            Article(
                                soruce: article.soruce,
                                title: article.title,
                                author: article.author,
                                content: article.content,
                                url: article.url,
                                imageUrl: article.imageUrl,
                                isFavorite: cachedArticles.contains { $0.url == article.url }
                            )
                        }
                        
                        completionHandler(.success(articles))
                        
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func articleImage(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        apiDataSource.articleImage(url: url, completionHandler: completionHandler)
    }
    
    func addArticleToFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        cacheDataSource.addToFavorite(article: article, completionHandler: completionHandler)
    }
    
    func removeArticleFromFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        cacheDataSource.removeFromFavorite(article: article, completionHandler: completionHandler)
    }
    
    func favoriteArticles(limit: Int, offset: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void) {
        cacheDataSource.favoriteArticles(count: limit, offset: offset, sources: sources, where: query, completionHandler: completionHandler)
    }
}
