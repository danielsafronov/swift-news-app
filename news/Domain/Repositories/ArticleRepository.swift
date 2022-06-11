//
//  FeedRepository.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

protocol ArticleRepository {
    func articles(onPage page: Int, count pageSize: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void)
    func articleImage(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void)
    func addArticleToFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void)
    func removeArticleFromFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void)
    func favoriteArticles(limit: Int, offset: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void)
}
