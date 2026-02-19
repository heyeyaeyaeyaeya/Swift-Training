import SwiftUI

struct QuizScreenView: View {
    let quiz: Quiz
    @State private var selectedOptions: [Int?]
    @State private var showResult = false
    @State private var currentIndex = 0

    init(quiz: Quiz) {
        self.quiz = quiz
        _selectedOptions = State(initialValue: Array(repeating: nil, count: quiz.questions.count))
    }

    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            VStack(alignment: .leading, spacing: 16) {
                GeometryReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(quiz.questions.indices, id: \.self) { questionIndex in
                                QuizCardView(
                                    question: quiz.questions[questionIndex],
                                    questionIndex: questionIndex,
                                    selectedOptions: $selectedOptions
                                )
                                .frame(width: proxy.size.width)
                                .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.85)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.96)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                    .onScrollGeometryChange(for: Int.self) { geometry in
                        let width = max(1, geometry.containerSize.width)
                        let page = Int((geometry.contentOffset.x / width).rounded())
                        return min(max(page, 0), max(quiz.questions.count - 1, 0))
                    } action: { _, newValue in
                        if currentIndex != newValue {
                            currentIndex = newValue
                        }
                    }
                }
                .frame(height: 420)

                PageDotsView(count: quiz.questions.count, currentIndex: currentIndex)

                if showResult {
                    QuizResultCardView(score: score, total: quiz.questions.count)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Quiz")
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showResult)
        .onChange(of: selectedOptions) { _, newValue in
            let completed = newValue.allSatisfy { $0 != nil }
            if completed && !showResult {
                showResult = true
            }
        }
    }

    private var score: Int {
        zip(quiz.questions, selectedOptions).reduce(0) { partialResult, pair in
            let (question, selected) = pair
            return partialResult + (selected == question.correctIndex ? 1 : 0)
        }
    }
}

private struct PageDotsView: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color(red: 0.82, green: 0.44, blue: 0.76).opacity(0.75) : Color(red: 0.82, green: 0.44, blue: 0.76).opacity(0.25))
                    .frame(width: index == currentIndex ? 8 : 6, height: index == currentIndex ? 8 : 6)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    QuizScreenView(quiz: Quiz(questions: [
        QuizQuestion(question: "What is the capital of France?", options: ["Paris", "Berlin", "Rome", "Madrid"], correctIndex: 0),
        QuizQuestion(question: "Which planet is known as the Red Planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], correctIndex: 1),
        QuizQuestion(question: "What is 2 + 2?", options: ["3", "4", "5", "6"], correctIndex: 1),
        QuizQuestion(question: "Which ocean is the largest?", options: ["Atlantic", "Pacific", "Indian", "Arctic"], correctIndex: 1),
        QuizQuestion(question: "What is H2O?", options: ["Oxygen", "Hydrogen", "Water", "Helium"], correctIndex: 2)
    ]))
}
