//
//  ArticleDetailedViewModel.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

final class ArticleDetailedViewModel {
    @Published private (set) var article: Article? = nil
    @Published var loading: Bool = false
    
    init(article: Article) {
        self.article = article
    }
}
