//
//  Error.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Foundation

enum APIDataSourceError: Error {
    case malformedUrl
    case invalidUrl
    case invalidResponse
    case decodeError
    case responseError(Data, URLResponse)
    case unsupportedStatusCode

}
