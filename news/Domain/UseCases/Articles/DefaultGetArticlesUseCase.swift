//
//  DefaultGetArticlesUseCase.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

struct DefaultGetArticlesUseCase: GetArticlesUseCase {
    let repository: ArticleRepository
    
    func invoke(page: Int, pageSize: Int, sources: [String], query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void) {
        repository.articles(onPage: page, count: pageSize, sources: sources, where: query, completionHandler: completionHandler)
    }
}
