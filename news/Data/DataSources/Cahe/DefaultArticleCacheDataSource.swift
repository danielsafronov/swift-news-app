//
//  DefaultArticleCacheDataSource.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import Foundation
import CoreData

struct DefaultArticleCacheDataSource: ArticleCacheDataSource {
    let container: NSPersistentContainer
    
    func articles(byURI uris: [URL], completionHandler: (Result<[Article], Error>) -> Void) {
        let context = container.newBackgroundContext()
        let request = ArticleMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K IN %@", #keyPath(ArticleMO.url), uris)
        request.fetchLimit = uris.count
        
        do {
            let result = try context.fetch(request)
            let articles = result.map { mo in
                Article(
                    soruce: mo.source,
                    title: mo.title,
                    author: mo.author,
                    content: mo.content,
                    url: mo.url!,
                    imageUrl: mo.imageUrl,
                    isFavorite: true
                )
            }
            
            completionHandler(.success(articles))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func favoriteArticles(count: Int, offset: Int, sources: [String], where query: String?, completionHandler: (Result<[Article], Error>) -> Void) {
        let context = container.newBackgroundContext()
        let request = ArticleMO.fetchRequest()
        var predicates: [NSPredicate] = []
        
        let sourcePredicate = NSPredicate(format: "%K IN %@", #keyPath(ArticleMO.source), sources)
        predicates.append(sourcePredicate)

        if let query = query, !query.isEmpty {
            let titlePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(ArticleMO.title), query)
            predicates.append(titlePredicate)
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.fetchLimit = count
        request.fetchOffset = offset
        
        do {
            let result = try context.fetch(request)
            let articles = result.map { mo in
                Article(
                    soruce: mo.source,
                    title: mo.title,
                    author: mo.author,
                    content: mo.content,
                    url: mo.url!,
                    imageUrl: mo.imageUrl,
                    isFavorite: true
                )
            }
            
            completionHandler(.success(articles))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func addToFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        let context = container.newBackgroundContext()
        let articleMO = ArticleMO(context: context)
        articleMO.author = article.author
        articleMO.content = article.content
        articleMO.source = article.soruce
        articleMO.title = article.title
        articleMO.imageUrl = article.imageUrl
        articleMO.url = article.url
        
        do {
            try context.save()
            completionHandler(.success(true))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func removeFromFavorite(article: Article, completionHandler: (Result<Bool, Error>) -> Void) {
        let context = container.newBackgroundContext()
        let request = ArticleMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(ArticleMO.url), article.url as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let item = try context.fetch(request).first {
                context.delete(item)
                try context.save()
            }
            
            completionHandler(.success(true))
        } catch {
            completionHandler(.failure(error))
        }
    }
}
