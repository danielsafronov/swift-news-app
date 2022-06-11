//
//  ArticleListViewModel.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation
import Combine

final class ArticleListViewModel {
    enum ArticleListFilter {
        case all
        case favorites
    }
    
    enum Source {
        case initial
        case infinite
    }
    
    private let startPage = 1
    private (set) var page = 1
    private (set) var pageSize = 20
    private let sources = ["techcrunch", "the-next-web"]
    
    @Published private (set) var items: [ArticleListItemViewModel] = []
    @Published private (set) var dataSource: ([ArticleListItemViewModel], Source) = ([], .initial)
    @Published private (set) var loading: Bool = false
    @Published private (set) var endReached: Bool = false
    @Published var query: String = ""
    @Published var filter: ArticleListFilter = .all
    
    private let getArticlesUseCase: GetArticlesUseCase
    private let getFavoriteArticlesUseCase: GetFavoriteArticlesUseCase
    private let getArticleImageUseCase: GetArticleImageUseCase
    private let addArticleToFavoriteUseCase: AddArticleToFavoriteUseCase
    private let removeArticleFromFavoriteUseCase: RemoveArticleFromFavoriteUseCase
    
    private var loadingWorkItem: DispatchWorkItem? = nil {
        willSet {
            if let loadingWorkItem = loadingWorkItem, !loadingWorkItem.isCancelled {
                loadingWorkItem.cancel()
            }
        }
    }
    
    init(getArticlesUseCase: GetArticlesUseCase, getFavoriteArticlesUseCase: GetFavoriteArticlesUseCase, getArticleImageUseCase: GetArticleImageUseCase, addArticleToFavoriteUseCase: AddArticleToFavoriteUseCase, removeArticleFromFavoriteUseCase: RemoveArticleFromFavoriteUseCase) {
        self.getArticlesUseCase = getArticlesUseCase
        self.getFavoriteArticlesUseCase = getFavoriteArticlesUseCase
        self.getArticleImageUseCase = getArticleImageUseCase
        self.addArticleToFavoriteUseCase = addArticleToFavoriteUseCase
        self.removeArticleFromFavoriteUseCase = removeArticleFromFavoriteUseCase
    }
    

    func indexes(forPage page: Int) -> [IndexPath] {
        let page = page
        var range = indexRange(page, fromPage: page - 1)
        let itemCountDiff = abs(page * range.count - items.count)
        if itemCountDiff > 0 {
            range.removeLast(itemCountDiff)
        }
        
        return indexes(forRange: range)
    }
    
    private func indexRange(_ page: Int, fromPage: Int) -> Range<Int> {
        let itemCount = pageSize
        let firstIndex = (fromPage * itemCount)
        let lastIndex = (page * itemCount)
        
        return firstIndex..<lastIndex
    }
    
    private func indexes(forRange range: Range<Int>) -> [IndexPath] {
        range.map { index in
            IndexPath(row: index, section: 0)
        }
    }
    
    func item(at indexPath: IndexPath) -> ArticleListItemViewModel? {
        let index = indexPath.row
        guard items.indices.contains(index) else {
            return nil
        }

        return items[index]
    }
    
    private func load(source: Source, page: Int, pageSize: Int, sources: [String], query: String? = nil, withReset reset: Bool = false, resultQueue: DispatchQueue = .main, completionHandler: ((Result<Bool, Error>) -> Void)? = nil) {
        let useCase = resolveGetArticlesUseCase(filter: filter)
        useCase.invoke(page: page, pageSize: pageSize, sources: sources, query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items):
                if let loadingWorkItem = self.loadingWorkItem, !loadingWorkItem.isCancelled {
                    let items = items.map {
                        ArticleListItemViewModel(
                            article: $0,
                            getArticleImageUseCase: self.getArticleImageUseCase,
                            addToFavoriteUseCase: self.addArticleToFavoriteUseCase,
                            removeArticleFromFavoriteUseCase: self.removeArticleFromFavoriteUseCase
                        )
                    }
                    
                    self.items = reset ? items : self.items + items
                    self.dataSource = (self.items, source)
                    self.endReached = items.count < self.pageSize
                }
                
                resultQueue.async {
                    completionHandler?(.success(true))
                }
                
            case .failure(let error):
                self.items = []
                self.dataSource = (self.items, source)
                self.endReached = true
                
                resultQueue.async {
                    completionHandler?(.failure(error))
                }
            }
            
            self.loadingWorkItem = nil
        }
    }
    
    private func resolveGetArticlesUseCase(filter: ArticleListFilter) -> GetArticlesUseCase {
        filter == .favorites ? getFavoriteArticlesUseCase : getArticlesUseCase
    }
}

extension ArticleListViewModel {
    func load() {
        guard !loading, items.isEmpty else {
            return
        }
        
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.loading = true
            self.page = self.startPage
            self.load(source: .initial, page: self.page, pageSize: self.pageSize, sources: self.sources, withReset: true, resultQueue: .global()) { [weak self] _ in
                self?.loading = false
            }
        }
        
        if let loadingWorkItem = loadingWorkItem {
            DispatchQueue.global().async(execute: loadingWorkItem)
        }
    }
    
    func loadNext() {
        guard !loading, !endReached, loadingWorkItem == nil else {
            return
        }
        
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.page += 1
            self.load(source: .infinite, page: self.page, pageSize: self.pageSize, sources: self.sources, query: self.query)
        }
        
        if let loadingWorkItem = loadingWorkItem {
            DispatchQueue.global().async(execute: loadingWorkItem)
        }
    }
    
    func refresh(resultQueue: DispatchQueue = .main, completionHandler: ((Result<Bool, Error>) -> Void)? = nil) {
        guard !loading else {
            return
        }
        
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.page = self.startPage
            self.query = ""
            self.load(source: .initial, page: self.page, pageSize: self.pageSize, sources: self.sources, withReset: true, resultQueue: resultQueue, completionHandler: completionHandler)
        }
        
        if let loadingWorkItem = loadingWorkItem {
            DispatchQueue.global().async(execute: loadingWorkItem)
        }
    }
    
    func search(query: String) {
        guard !query.isEmpty else { return }
        
        loadingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.loading = true
            self.page = self.startPage
            self.load(source: .initial, page: self.page, pageSize: self.pageSize, sources: self.sources, query: query, withReset: true, resultQueue: .main) { [weak self] _ in
                self?.loading = false
            }
        }
        
        if let loadingWorkItem = loadingWorkItem {
            DispatchQueue.global().async(execute: loadingWorkItem)
        }
    }
}
