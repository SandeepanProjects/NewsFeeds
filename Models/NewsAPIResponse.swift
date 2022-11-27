//
//  NewsFeedsApp.swift
//  NewsFeeds
//
//  Created by Apple on 26/11/22.
//

import Foundation

struct NewsAPIResponse: Decodable {
    
    let status: String
    let totalResults: Int?
    let articles: [Article]?
    
    let code: String?
    let message: String?
    
}
