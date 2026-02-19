import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.92, green: 0.96, blue: 1.0),
                Color(red: 0.96, green: 0.93, blue: 1.0),
                Color(red: 1.0, green: 0.97, blue: 0.93)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackgroundView()
}
