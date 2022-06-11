//
//  ArticleAPIModel.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

struct ArticleAPIModel: Codable {
    let source: ArticleSourceAPIModel
    let author: String?
    let title: String?
    let content: String?
    let url: URL
    let imageUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case content
        case url
        case imageUrl = "urlToImage"
    }
}
