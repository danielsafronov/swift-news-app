//
//  GetArticlesUseCase.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

protocol GetArticlesUseCase {
    func invoke(page: Int, pageSize: Int, sources: [String], query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void)
}
