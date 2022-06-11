//
//  ArticlePageAPIModel.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

struct ArticlePageAPIModel: Codable {
    let status: String
    let totalCount: Int
    let items: [ArticleAPIModel]
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalCount = "totalResults"
        case items = "articles"
    }
}
