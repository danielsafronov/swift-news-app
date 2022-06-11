//
//  ArticleAPIDataSource.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

protocol ArticleAPIDataSource {
    func articles(onPage page: Int, count pageSize: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void)
    func articleImage(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void)
}
