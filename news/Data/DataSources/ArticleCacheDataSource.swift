//
//  ArticleCacheDataSource.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

protocol ArticleCacheDataSource {
    func articles(byURI uris: [URL], completionHandler: (Result<[Article], Error>) -> Void)
    func favoriteArticles(count: Int, offset: Int, sources: [String], where query: String?, completionHandler: (Result<[Article], Error>) -> Void)
    func addToFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void)
    func removeFromFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void)
}
