//
//  NewsFeedsApp.swift
//  NewsFeeds
//
//  Created by Apple on 26/11/22.
//

import SwiftUI

struct ArticleListView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedArticleURL: URL?
    let articles: [Article]
    var isFetchingNextPage = false
    var nextPageHandler: (() async -> ())? = nil
    
    var body: some View {
        rootView
        .sheet(item: $selectedArticleURL) {
            SafariView(url: $0)
                .edgesIgnoringSafeArea(.bottom)
                .id($0)
        }
        .onReceive(NotificationCenter.default.publisher(for: .articleSent, object: nil)) { notification in
            if let url = notification.userInfo?["url"] as? URL,
               url != selectedArticleURL {
                selectedArticleURL = url
            }
        }
    }
    
    @ViewBuilder
    private var bottomProgressView: some View {
        Divider()
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }.padding()
    }
    
    private var listView: some View {
        List {
            ForEach(articles) { article in
                if let nextPageHandler = nextPageHandler, article == articles.last {
                    listRowView(for: article)
                        .task { await nextPageHandler() }
                    
                    if isFetchingNextPage {
                        bottomProgressView
                    }
                    
                } else {
                    listRowView(for: article)
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func listRowView(for article: Article) -> some View {
        ArticleRowView(article: article)
            .onTapGesture {
                selectedArticleURL = article.articleURL
            }
    }
        
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: gridSpacing) {
                ForEach(articles) { article in
                    if let nextPageHandler = nextPageHandler, article == articles.last {
                        gridItemView(for: article)
                            .task { await nextPageHandler() }
                    } else {
                        gridItemView(for: article)
                    }
                }
            }
            .padding()
            
            if isFetchingNextPage {
                bottomProgressView
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
    
    @ViewBuilder
    private func gridItemView(for article: Article) -> some View {
        ArticleRowView(article: article)
            .onTapGesture { handleOnTapGesture(article: article) }
            .frame(height: 360)
            .background(Color(uiColor: .systemBackground))
    }
    
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 300), spacing: 8)]
    }
    
    private var gridSpacing: CGFloat? {
        nil
    }
    
    private func handleOnTapGesture(article: Article) {
        self.selectedArticleURL = article.articleURL
    }
    
    @ViewBuilder
    private var rootView: some View {
        switch horizontalSizeClass {
        case .regular:
            gridView
        default:
            listView
        }
    }
    
}

extension URL: Identifiable {
    
    public var id: String { absoluteString }
    
}

struct ArticleListView_Previews: PreviewProvider {
    
    @StateObject static var articleBookmarkVM = ArticleBookmarkViewModel.shared
    
    static var previews: some View {
        NavigationView {
            ArticleListView(articles: Article.previewData)
                .environmentObject(articleBookmarkVM)
        }
    }
}
