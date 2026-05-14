import SwiftUI
import WebKit

/// Embeds the bundled `onboarding_video.html` animation in a SwiftUI view.
///
/// The HTML auto-scales itself to whatever size the WebView gets, so this
/// view fills its container while preserving the 1290×2796 design space.
struct PhoneMockupWebView: UIViewRepresentable {
    /// Bundle resource name (without extension)
    let resourceName: String

    /// Reload the WebView (and thus restart the animation) whenever this
    /// value changes. SwiftUI calls `updateUIView` automatically.
    var reloadToken: Int = 0

    init(resourceName: String = "onboarding_video", reloadToken: Int = 0) {
        self.resourceName = resourceName
        self.reloadToken = reloadToken
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isUserInteractionEnabled = false

        load(into: webView)
        context.coordinator.lastToken = reloadToken
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard reloadToken != context.coordinator.lastToken else { return }
        context.coordinator.lastToken = reloadToken
        load(into: webView)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var lastToken: Int = -1
    }

    private func load(into webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "html") else {
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
