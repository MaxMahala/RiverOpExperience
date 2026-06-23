import Foundation
import UIKit
import WebKit
import SwiftUI
import SpriteKit

class DInit_DMmUIWeb_mvmsgnIOOF45643: UIViewController, WKUIDelegate {
    private var webView: WKWebView!
    private let toolbar = UIToolbar()
    var initialURL: URL?
    
    init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.initialURL = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        configureWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadURL()
    }
    
    private func configureWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        webConfiguration.userContentController = contentController
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/102.0.5005.87 Mobile/15E148 Safari/604.1"
        view = webView
    }
    
    private func setupUI() {
        setupWebViewAndToolbar()
        setupGestureRecognizers()
    }
    
    private func setupWebViewAndToolbar() {
        let containerView = UIView()
        containerView.backgroundColor = .black
        
        containerView.addSubview(webView)
        containerView.addSubview(toolbar)
        view = containerView
        
        toolbar.isHidden = true
        toolbar.backgroundColor = .clear
        toolbar.isTranslucent = true
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let toolbarHeightZero = toolbar.heightAnchor.constraint(equalToConstant: 0)
        toolbarHeightZero.isActive = true
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            
            toolbar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupGestureRecognizers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        swipeRight.direction = .right
        webView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goForward))
        swipeLeft.direction = .left
        webView.addGestureRecognizer(swipeLeft)
    }
    
    func loadURL() {
        if let url = initialURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc private func refreshPage() {
        webView.reload()
    }
    
    #warning("update for open new window")
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "policyAgreed")
    }
}
