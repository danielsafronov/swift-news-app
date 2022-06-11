//
//  RootContainer.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation
import CoreData

final class Container {
    let urlSession: URLSession
    let persistentContainer: NSPersistentContainer
    
    init(urlSession: URLSession, persistentContainer: NSPersistentContainer) {
        self.urlSession = urlSession
        self.persistentContainer = persistentContainer
    }
    
    func makeArticleRepository() -> ArticleRepository {
        DefaultArticleRepository(
            apiDataSource: makeArticleAPIDataSource(),
            cacheDataSource: makeArticleCacheDataSource()
        )
    }
    
    func makeArticleAPIDataSource() -> ArticleAPIDataSource {
        let apiScheme = Configuration.requiredString(byKey: "API_SCHEME")
        let apiBaseUrl = Configuration.requiredString(byKey: "API_BASE_URL")
        let apiKey = Configuration.requiredString(byKey: "API_KEY")
        
        let baseUrl = "\(apiScheme)://\(apiBaseUrl)"
        
        return DefaultArticleAPIDataSource(
            session: urlSession,
            configuration: .init(
                baseUrl: baseUrl,
                apiKey: apiKey
            )
        )
    }
    
    func makeArticleCacheDataSource() -> ArticleCacheDataSource {
        DefaultArticleCacheDataSource(
            container: persistentContainer
        )
    }
    
    func makeGetArticlesUseCase() -> GetArticlesUseCase {
        DefaultGetArticlesUseCase(repository: makeArticleRepository())
    }
    
    func makeGetFavoriteArticlesUseCase() -> GetFavoriteArticlesUseCase {
        DefaultGetFavoriteArticlesUseCase(repository: makeArticleRepository())
    }
    
    func makeGetArticleImageUseCase() -> GetArticleImageUseCase {
        DefaultGetArticleImageUseCase(repository: makeArticleRepository())
    }
    
    func makeAddArticleToFavoriteUseCase() -> AddArticleToFavoriteUseCase {
        DefaultAddArticleToFavoriteUseCase(repository: makeArticleRepository())
    }
    
    func makeRemoveArticleFromFavoriteUseCase() -> RemoveArticleFromFavoriteUseCase {
        DefaultRemoveArticleFromFavoriteUseCase(repository: makeArticleRepository())
    }
    
    func makeArticleListViewModel() -> ArticleListViewModel {
        ArticleListViewModel(
            getArticlesUseCase: makeGetArticlesUseCase(),
            getFavoriteArticlesUseCase: makeGetFavoriteArticlesUseCase(),
            getArticleImageUseCase: makeGetArticleImageUseCase(),
            addArticleToFavoriteUseCase: makeAddArticleToFavoriteUseCase(),
            removeArticleFromFavoriteUseCase: makeRemoveArticleFromFavoriteUseCase()
        )
    }
    
    func makeArticleDetailedViewModel(article: Article) -> ArticleDetailedViewModel {
        ArticleDetailedViewModel(article: article)
    }
}
