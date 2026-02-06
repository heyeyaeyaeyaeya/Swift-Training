import SwiftUI

struct QuizCardView: View {
    let question: QuizQuestion
    let questionIndex: Int
    @Binding var selectedOptions: [Int?]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(questionIndex + 1). \(question.question)")
                .multilineTextAlignment(.leading)
                .font(.headline)
            ForEach(question.options.indices, id: \.self) { optionIndex in
                let selected = selectedOptions.indices.contains(questionIndex) ? selectedOptions[questionIndex] : nil
                let isSelected = selected == optionIndex
                let isCorrect = optionIndex == question.correctIndex
                let isAnswered = selected != nil
                Button {
                    if selected == nil {
                        selectedOptions[questionIndex] = optionIndex
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(question.options[optionIndex])
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .layoutPriority(1)
                        if isAnswered {
                            if isCorrect {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if isSelected {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.18) : Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
                .allowsHitTesting(selected == nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    QuizCardViewPreview()
}

private struct QuizCardViewPreview: View {
    @State private var selections: [Int?] = [nil]

    var body: some View {
        QuizCardView(
            question: QuizQuestion(
                question: "Which planet is known as the Red Planet?",
                options: ["Earth", "Mars", "Jupiter", "Venus"],
                correctIndex: 1
            ),
            questionIndex: 0,
            selectedOptions: $selections
        )
    }
}
