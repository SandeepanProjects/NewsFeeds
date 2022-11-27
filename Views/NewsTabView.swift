//
//  NewsFeedsApp.swift
//  NewsFeeds
//
//  Created by Apple on 26/11/22.
//

import SwiftUI

struct NewsTabView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var articleNewsVM: ArticleNewsViewModel
    
    init(articles: [Article]? = nil, category: Category = .general) {
        self._articleNewsVM = StateObject(wrappedValue: ArticleNewsViewModel(articles: articles, selectedCategory: category))
    }
    
    var body: some View {
        ArticleListView(articles: articleNewsVM.articles, isFetchingNextPage: articleNewsVM.isFetchingNextPage, nextPageHandler: { await articleNewsVM.loadNextPage() })
            .overlay(overlayView)
            .task(id: articleNewsVM.fetchTaskToken, loadTask)
            .refreshable(action: refreshTask)
            .navigationTitle(articleNewsVM.fetchTaskToken.category.text)
            .navigationBarItems(trailing: navigationBarItem)
    }
    
    @ViewBuilder
    private var overlayView: some View {
        
        switch articleNewsVM.phase {
        case .empty:
            ProgressView()
        case .success(let articles) where articles.isEmpty:
            EmptyPlaceholderView(text: "No Articles", image: nil)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
        default: EmptyView()
        }
    }
    
    @Sendable
    private func loadTask() async {
        await articleNewsVM.loadFirstPage()
    }
    
    @Sendable
    private func refreshTask() {
        Task {
            await articleNewsVM.refreshTask()
        }
    }
    
    @ViewBuilder
    private var navigationBarItem: some View {
        switch horizontalSizeClass {
        case .regular:
            Button(action: refreshTask) {
                Image(systemName: "arrow.clockwise")
                    .imageScale(.large)
            }
            
        default:
            Menu {
                Picker("Category", selection: $articleNewsVM.fetchTaskToken.category) {
                    ForEach(Category.allCases) {
                        Text($0.text).tag($0)
                    }
                }
            } label: {
                Image(systemName: "fiberchannel")
                    .imageScale(.large)
            }
        }
    }
}

struct NewsTabView_Previews: PreviewProvider {
    
    @StateObject static var articleBookmarkVM = ArticleBookmarkViewModel.shared

    
    static var previews: some View {
        NewsTabView(articles: Article.previewData)
            .environmentObject(articleBookmarkVM)
    }
}
