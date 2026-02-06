//
//  ContentView.swift
//  WikiScroll
//
//  Created by Sergey Leontiev on 6. 2. 2026..
//

import Foundation
import SwiftUI
import WebKit

struct ContentView: View {
    @State private var articles: [Article] = []
    @State private var isLoading = false
    @State private var nextContinueToken: String? = nil
    @State private var continueToken: String? = nil
    @State private var hasMore = true
    @State private var selectedArticle: Article? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(articles) { article in
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(article.title)
                                    .font(.headline)
                                if let extract = article.extract, !extract.isEmpty {
                                    Text(extract)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(5)
                                }
                            }
                            Spacer()
                            if let thumbnailURL = article.thumbnailURL {
                                AsyncImage(url: thumbnailURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                        .frame(height: 150, alignment: .center)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedArticle = article
                        }
                        .onAppear {
                            loadMoreIfNeeded(current: article)
                        }
                    }
                    .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.75)
                            .blur(radius: phase.isIdentity ? 0 : 10)
                    }
                    .padding(.horizontal, 10)
                }
                .scrollTargetLayout()
                .padding(.vertical, 6)
                
                if hasMore {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task {
                                await fetchArticles()
                            }
                        }
                }
                
                if isLoading && !articles.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .navigationTitle("WikiScroll")
            .navigationDestination(item: $selectedArticle) { article in
                ArticleDetailView(pageid: article.pageid, title: article.title)
            }
            .background(Color(.systemGroupedBackground))
            .overlay {
                if articles.isEmpty {
                    ProgressView()
                }
            }
        }
        .task {
            await fetchArticles()
        }
    }

    private func loadMoreIfNeeded(current article: Article) {
        guard let index = articles.firstIndex(of: article) else {
            return
        }

        let thresholdIndex = articles.index(articles.endIndex, offsetBy: -7, limitedBy: articles.startIndex) ?? articles.startIndex
        if index >= thresholdIndex {
            Task {
                await fetchArticles()
            }
        }
    }

    @MainActor
    private func fetchArticles() async {
        guard !isLoading, hasMore else {
            return
        }

        isLoading = true
        print("Fetch start. currentCount=\(articles.count)")
        defer { isLoading = false }

        var components = URLComponents(string: "https://ru.wikipedia.org/w/api.php")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "extracts|pageimages"),
            URLQueryItem(name: "generator", value: "random"),
            URLQueryItem(name: "formatversion", value: "2"),
            URLQueryItem(name: "exintro", value: "1"),
            URLQueryItem(name: "explaintext", value: "1"),
            URLQueryItem(name: "piprop", value: "thumbnail"),
            URLQueryItem(name: "pithumbsize", value: "200"),
            URLQueryItem(name: "grnnamespace", value: "0"),
            URLQueryItem(name: "grnminsize", value: "10000"),
            URLQueryItem(name: "grnlimit", value: "10")
        ]

        if let nextContinueToken {
            queryItems.append(URLQueryItem(name: "grncontinue", value: nextContinueToken))
        }

        if let continueToken {
            queryItems.append(URLQueryItem(name: "continue", value: continueToken))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WikiResponse.self, from: data)
            let newPages = response.query?.pages ?? []
            let existingIDs = Set(articles.map { $0.id })
            let uniqueNewArticles = newPages.filter { !existingIDs.contains($0.pageid) }.map {
                Article(pageid: $0.pageid, title: $0.title, extract: $0.extract, thumbnailURL: $0.thumbnail?.url)
            }
            articles.append(contentsOf: uniqueNewArticles)
            print("Fetch end. added=\(uniqueNewArticles.count) total=\(articles.count)")

            if let token = response.continueInfo?.grncontinue {
                nextContinueToken = token
                continueToken = response.continueInfo?.continueValue
                hasMore = true
            } else {
                hasMore = false
            }
        } catch {
            hasMore = false
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
}

private struct ArticleDetailView: View {
    let pageid: Int
    let title: String
    @State private var text: String? = nil
    @State private var isLoading = false
    @State private var loadError: String? = nil

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let loadError {
                Text(loadError)
                    .foregroundStyle(.secondary)
            } else if text != nil {
                WebViewSUI(url: URL(string: "https://ru.wikipedia.org/wiki/\(title)")!)
            } else {
                Text("No content.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadArticleInfo()
        }
    }

    @MainActor
    private func loadArticleInfo() async {
        guard !isLoading else { return }
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        var components = URLComponents(string: "https://ru.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "parse"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "text"),
            URLQueryItem(name: "mobileformat", value: "1"),
            URLQueryItem(name: "redirects", value: "1"),
            URLQueryItem(name: "pageid", value: String(pageid))
        ]

        guard let url = components?.url else {
            loadError = "Failed to build request."
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WikiParseResponse.self, from: data)
            text = response.parse?.text?.html
        } catch {
            loadError = "Failed to load article."
        }
    }
}

private struct Article: Identifiable, Hashable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnailURL: URL?

    var id: Int {
        pageid
    }
}

private struct WikiResponse: Decodable {
    let query: WikiQuery?
    let continueInfo: WikiContinue?

    private enum CodingKeys: String, CodingKey {
        case query
        case continueInfo = "continue"
    }
}

private struct WikiQuery: Decodable {
    let pages: [WikiPage]
}

private struct WikiPage: Decodable {
    let pageid: Int
    let title: String
    let extract: String?
    let thumbnail: WikiThumbnail?
}

private struct WikiThumbnail: Decodable {
    let url: URL

    private enum CodingKeys: String, CodingKey {
        case url = "source"
    }
}

private struct WikiContinue: Decodable {
    let grncontinue: String?
    let continueValue: String?

    private enum CodingKeys: String, CodingKey {
        case grncontinue
        case continueValue = "continue"
    }
}

private struct WikiParseResponse: Decodable {
    let parse: WikiParse?
}

private struct WikiParse: Decodable {
    let title: String?
    let pageid: Int?
    let text: WikiParseText?
}

private struct WikiParseText: Decodable {
    let html: String

    private enum CodingKeys: String, CodingKey {
        case html = "*"
    }
}

#Preview {
    ContentView()
}

struct WebViewSUI: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
