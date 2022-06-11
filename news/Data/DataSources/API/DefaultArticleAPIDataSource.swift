//
//  DefaultFeedAPIDataSource.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation
import UIKit

struct DefaultArticleAPIDataSource: ArticleAPIDataSource {
    let session: URLSession
    let configuration: APIConfiguration
    
    func articles(onPage page: Int, count pageSize: Int, sources: [String], where query: String?, completionHandler: @escaping (Result<[Article], Error>) -> Void) {
        do {
            var parameters = ["sources": sources.joined(separator: ","), "page": String(page)]
            if let query = query {
                parameters["q"] = query
                parameters["searchIn"] = "title"
            }
            
            let url = try APIURLResolver(configuration: configuration).resolveURL(path: "everything", parameters: parameters)
            print(url.absoluteURL)
            
            let task = session.dataTask(with: url) { data, response, error in
                guard
                    let data = data,
                    let httpUrlResponse = response as? HTTPURLResponse,
                    httpUrlResponse.statusCode == 200
                else {
                    completionHandler(.failure(APIDataSourceError.invalidResponse))
                    return
                }
                
                do {
                    _ = try JSONDecoder().decode(ArticlePageAPIModel.self, from: data)
                } catch {
                    //
                    print(error)
                }
                
                guard let page = try? JSONDecoder().decode(ArticlePageAPIModel.self, from: data) else {
                    completionHandler(.failure(APIDataSourceError.decodeError))
                    return
                }
                
                let items = page.items.map { item in
                    Article(
                        soruce: item.source.id,
                        title: item.title,
                        author: item.author,
                        content: item.content,
                        url: item.url,
                        imageUrl: item.imageUrl,
                        isFavorite: false
                    )
                }
                
                completionHandler(.success(items))
            }
            
            task.resume()
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    func articleImage(url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let httpUrlResponse = response as? HTTPURLResponse,
                httpUrlResponse.statusCode == 200
            else {
                completionHandler(.failure(APIDataSourceError.invalidResponse))
                return
            }
            
            completionHandler(.success(data))
        }
        
        task.resume()
    }
}

struct APIConfiguration {
    let baseUrl: String
    let apiKey: String
}

fileprivate struct APIURLResolver {
    typealias Parameters = [String: String]
    
    let configuration: APIConfiguration
    
    func resolveURL(path: String, parameters: Parameters) throws -> URL {
        var parameters = parameters
        parameters["apiKey"] = configuration.apiKey
        
        let urlComponents = try resolveURLComponents(url: "\(configuration.baseUrl)/\(path)", parameters: parameters)
        guard let url = urlComponents.url else {
            throw APIDataSourceError.invalidUrl
        }
        
        return url
    }
    
    private func resolveURLComponents(url: String, parameters: Parameters) throws -> URLComponents {
        let urlComponents = URLComponents(string: url)
        guard var urlComponents = urlComponents else {
            throw APIDataSourceError.malformedUrl
        }
        
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return urlComponents
    }
}
