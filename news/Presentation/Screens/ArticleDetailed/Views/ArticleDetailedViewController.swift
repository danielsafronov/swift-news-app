//
//  ArticleDetailedViewController.swift
//  news
//
//  Created by Daniel Safronov on 10.06.2022.
//

import WebKit
import UIKit
import Combine

final class ArticleDetailedViewController: UIViewController {
    private let viewModel: ArticleDetailedViewModel
    private var cancellable = Set<AnyCancellable>()
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    init(viewModel: ArticleDetailedViewModel, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        observe()
    }
    
    private func configure() {
        configureWebView()
    }
    
    private func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }
    
    private func observe() {
        observeArticle()
        observeLoading()
    }
    
    private func observeArticle() {
        viewModel.$article
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] article in
                self?.didChangeArticle(article)
            }
            .store(in: &cancellable)
    }
    
    private func observeLoading() {
        viewModel.$loading
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.didChangeLoading(state)
            }
            .store(in: &cancellable)
    }
    
    private func didChangeArticle(_ article: Article) {
        let url = article.url
        webView.load(URLRequest(url: url))
    }
    
    private func didChangeLoading(_ state: Bool) {
        webView.isHidden = state
        activityIndicator.isHidden = !state
        
        state ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension ArticleDetailedViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.loading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.loading = false
    }
}

extension ArticleDetailedViewController {
    static func instantiate(viewModel: ArticleDetailedViewModel) -> UIViewController {
        ArticleDetailedViewController(viewModel: viewModel, nibName: "ArticleDetailedViewController", bundle: nil)
    }
}
