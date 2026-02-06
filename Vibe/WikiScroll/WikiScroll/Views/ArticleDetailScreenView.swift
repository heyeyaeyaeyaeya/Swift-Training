import Foundation
import SwiftUI
import FoundationModels

struct ArticleDetailScreenView: View {
    let pageid: Int
    let title: String
    private let previewURL: URL?
    @State private var quiz: Quiz? = nil
    @State private var isGeneratingQuiz = false

    init(pageid: Int, title: String, previewQuiz: Quiz? = nil, previewURL: URL? = nil) {
        self.pageid = pageid
        self.title = title
        self.previewURL = previewURL
        _quiz = State(initialValue: previewQuiz)
    }

    var body: some View {
        WebViewRepresentableView(url: previewURL ?? URL(string: "https://en.wikipedia.org/wiki/\(title)")!)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let quiz {
                        NavigationLink("Quiz") {
                            QuizScreenView(quiz: quiz)
                        }
                    } else if isGeneratingQuiz {
                        ProgressView()
                    }
                }
            }
            .background(GradientBackgroundView())
            .task(id: pageid) {
                await generateQuiz()
            }
    }

    private func loadArticleInfo() async -> String? {
        var components = URLComponents(string: "https://en.wikipedia.org/w/api.php")
        components?.queryItems = [
            URLQueryItem(name: "action", value: "parse"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "text"),
            URLQueryItem(name: "mobileformat", value: "1"),
            URLQueryItem(name: "redirects", value: "1"),
            URLQueryItem(name: "pageid", value: String(pageid))
        ]

        guard let url = components?.url else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(WikiParseResponse.self, from: data)
            return response.parse?.text?.html
        } catch {
            return nil
        }
    }

    @MainActor private func generateQuiz() async {
        guard quiz == nil, !isGeneratingQuiz else { return }
        isGeneratingQuiz = true

        defer { isGeneratingQuiz = false }

        let model = SystemLanguageModel.default
        if !model.isAvailable {
            return
        }

        guard let htmlText = await loadArticleInfo(), let plainText = plainText(from: htmlText) else {
            return
        }

        let trimmedText = String(plainText.prefix(4000))
        let instructions = """
        You are an assistant that creates short quizzes from source text.
        Respond only in English.
        """
        let prompt = """
        The input below is HTML from a Wikipedia page. Ignore all HTML tags, markup, styles, and navigation text.
        Create a 5-question quiz about the article content only. Each question must have 4 answer options and exactly one correct answer.
        Do NOT ask any questions about HTML, CSS, or the markup itself.
        HTML Text:
        \(trimmedText)
        """

        do {
            let session = LanguageModelSession(model: model, instructions: instructions)
            let response = try await session.respond(to: prompt, generating: Quiz.self)
            quiz = response.content
        } catch {
            quiz = nil
        }
    }

    private func plainText(from html: String) -> String? {
        guard let data = html.data(using: .utf8) else {
            return nil
        }

        do {
            let attributed = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return attributed.string
        } catch {
            return nil
        }
    }
}

#Preview {
    NavigationStack {
        ArticleDetailScreenView(
            pageid: 1,
            title: "Apple",
            previewQuiz: Quiz(questions: [
                QuizQuestion(question: "What is the capital of France?", options: ["Paris", "Berlin", "Rome", "Madrid"], correctIndex: 0),
                QuizQuestion(question: "Which planet is known as the Red Planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], correctIndex: 1),
                QuizQuestion(question: "What is 2 + 2?", options: ["3", "4", "5", "6"], correctIndex: 1),
                QuizQuestion(question: "Which ocean is the largest?", options: ["Atlantic", "Pacific", "Indian", "Arctic"], correctIndex: 1),
                QuizQuestion(question: "What is H2O?", options: ["Oxygen", "Hydrogen", "Water", "Helium"], correctIndex: 2)
            ]),
            previewURL: URL(string: "about:blank")
        )
    }
}
