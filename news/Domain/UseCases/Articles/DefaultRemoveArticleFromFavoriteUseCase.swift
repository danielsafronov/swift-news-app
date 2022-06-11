//
//  DefaultRemoveArticleFromFavoriteUseCase.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

struct DefaultRemoveArticleFromFavoriteUseCase: RemoveArticleFromFavoriteUseCase {
    let repository: ArticleRepository
    
    func invoke(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        repository.removeArticleFromFavorite(article: article, completionHandler: completionHandler)
    }
}
