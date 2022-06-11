//
//  DefaultGetArticleImageUseCase.swift
//  news
//
//  Created by Daniel Safronov on 09.06.2022.
//

import Foundation

struct DefaultGetArticleImageUseCase: GetArticleImageUseCase {
    let repository: ArticleRepository
    
    func invoke(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        repository.articleImage(url: url, completionHandler: completionHandler)
    }
}
