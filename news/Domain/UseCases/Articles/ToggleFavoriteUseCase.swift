//
//  ToggleFavoriteUseCase.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

protocol ToggleFavoriteUseCase {
    func invoke(article: Article, completionHandler: (Result<Bool, Error>) -> Void)
}
