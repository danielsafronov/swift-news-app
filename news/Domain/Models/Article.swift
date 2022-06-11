//
//  Article.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

struct Article {
    let soruce: String?
    let title: String?
    let author: String?
    let content: String?
    let url: URL
    let imageUrl: URL?
    var isFavorite: Bool
}
