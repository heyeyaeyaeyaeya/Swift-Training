import SwiftUI

struct QuizResultCardView: View {
    let score: Int
    let total: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Result")
                    .font(.headline)
                Text("\(score) / \(total)")
                    .font(.title)
            }
            Spacer()
            Image(systemName: score == total ? "trophy.fill" : "sparkles")
                .font(.title)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
}

#Preview {
    QuizResultCardView(score: 4, total: 5)
        .padding()
        .background(GradientBackgroundView())
}
