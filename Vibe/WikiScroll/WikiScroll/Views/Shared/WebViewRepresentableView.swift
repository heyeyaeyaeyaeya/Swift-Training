import SwiftUI
import WebKit

struct WebViewRepresentableView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

#Preview {
    WebViewRepresentableView(url: URL(string: "https://en.wikipedia.org/wiki/Apple")!)
}
