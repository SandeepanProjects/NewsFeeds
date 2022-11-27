//
//  NewsFeedsApp.swift
//  NewsFeeds
//
//  Created by Apple on 26/11/22.
//

import Foundation

struct CategoryArticles: Codable {
    
    let category: Category
    let articles: [Article]
}
