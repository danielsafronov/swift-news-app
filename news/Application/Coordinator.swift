//
//  RootCoordinator.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation
import UIKit

class Coordinator {
    private let rootContainer: Container
    private let rootController: UINavigationController
    
    init(rootContainer: Container, rootController: UINavigationController) {
        self.rootContainer = rootContainer
        self.rootController = rootController
    }
    
    func start() {
        coordinateToArticleList()
    }
    
    func coordinateToArticleList() {
        let controller = ArticleListViewController.instantiate(viewModel: rootContainer.makeArticleListViewModel())
        controller.delegate = self
        
        rootController.pushViewController(controller, animated: true)
    }
    
    func coordinateToArticleDetailed(article: Article) {
        let controller = ArticleDetailedViewController.instantiate(viewModel: rootContainer.makeArticleDetailedViewModel(article: article))
        rootController.pushViewController(controller, animated: true)
    }
}

extension Coordinator: ArticleListViewControllerDelegate {
    func didSelectArticle(_ article: Article) {
        coordinateToArticleDetailed(article: article)
    }
}
