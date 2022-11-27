//
//  NewsFeedsApp.swift
//  NewsFeeds
//
//  Created by Apple on 26/11/22.
//

import Foundation

enum DataFetchPhase<T> {
    
    case empty
    case success(T)
    case fetchingNextPage(T)
    case failure(Error)
    
    var value: T? {
        if case .success(let value) = self {
            return value
        } else if case .fetchingNextPage(let value) = self {
            return value
        }
        return nil
    }
    
}
