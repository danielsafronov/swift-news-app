//
//  ArticleListViewControllerDelegate.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation

protocol ArticleListViewControllerDelegate: AnyObject {
    func didSelectArticle(_ article: Article)
}
