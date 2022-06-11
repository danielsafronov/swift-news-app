//
//  DefaultAddFavoriteUseCase.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

struct DefaultAddArticleToFavoriteUseCase: AddArticleToFavoriteUseCase {
    let repository: ArticleRepository
    
    func invoke(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        repository.addArticleToFavorite(article: article, completionHandler: completionHandler)
    }
}
