//
//  GetArticleImageUseCase.swift
//  news
//
//  Created by Daniel Safronov on 09.06.2022.
//

import Foundation

protocol GetArticleImageUseCase {
    func invoke(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void)
}
