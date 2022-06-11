//
//  DefaultGetFavoriteArticlesUseCase.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

struct DefaultGetFavoriteArticlesUseCase: GetFavoriteArticlesUseCase {
    let repository: ArticleRepository
    
    func invoke(page: Int, pageSize: Int, sources: [String], query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void) {
        let limit = pageSize
        let offset = max(0, page - 1) * pageSize
        
        repository.favoriteArticles(limit: limit, offset: offset, sources: sources, where: query, completionHandler: completionHandler)
    }
}
