//
//  ArticleListViewController.swift
//  news
//
//  Created by Daniel Safronov on 08.06.2022.
//

import Combine
import UIKit

final class ArticleListViewController: UIViewController {
    
    private let viewModel: ArticleListViewModel
    private var cancellable = Set<AnyCancellable>()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    private lazy var searchController = UISearchController()
    private lazy var refreshControl = UIRefreshControl()
    
    weak var delegate: ArticleListViewControllerDelegate?
    
    init(viewModel: ArticleListViewModel, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configure() {
        configureNavigateionBar()
        configureRefreshControl()
        configureSerachController()
        configureTableView()
    }
    
    private func configureNavigateionBar() {
        let systemName = viewModel.filter == .all ? "star" : "star.fill"
        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: systemName), style: .plain, target: self, action: #selector(didTapFavorite))
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: ArticleListItemViewCell.nib, bundle: nil), forCellReuseIdentifier: ArticleListItemViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(didChangeRefreshControl), for: .valueChanged)
    }
    
    private func configureSerachController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter text to search..."
        searchController.searchBar.delegate = self
        searchController.definesPresentationContext = true
        
        navigationItem.searchController = searchController
    }
    
    private func observe() {
        observeArticles()
        observeLoading()
        observeFilter()
        observeQuery()
    }
    
    private func observeArticles() {
        viewModel.$dataSource
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items, source in
                self?.didChangeArticles(items, source: source)
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
    
    private func observeFilter() {
        viewModel.$filter
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                self?.didChangeFilter(filter)
            }
            .store(in: &cancellable)
    }
    
    private func observeQuery() {
        viewModel.$query
            .subscribe(on: DispatchQueue.global())
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query in
                self?.didChangeQuery(query)
            }
            .store(in: &cancellable)
    }
    
    private func didChangeArticles(_ items: [ArticleListItemViewModel]) {
        let isItemsEmpty = items.isEmpty
        
        tableView.isHidden = isItemsEmpty
        noDataLabel.isHidden = !isItemsEmpty
        
        if !isItemsEmpty {
            tableView.reloadData()
        }
    }
    
    private func didChangeArticles(_ items: [ArticleListItemViewModel], source: ArticleListViewModel.Source) {
        let isItemsEmpty = items.isEmpty
        
        tableView.isHidden = isItemsEmpty
        noDataLabel.isHidden = !isItemsEmpty
        
        guard !isItemsEmpty else { return }
        switch source {
        case .initial:
            tableView.reloadData()
            
        case .infinite:
            let indexes = viewModel.indexes(forPage: viewModel.page)
            tableView.insertRows(at: indexes, with: .fade)
        }
    }
    
    private func didChangeLoading(_ state: Bool) {
        tableView.isHidden = state
        activityIndicator.isHidden = !state
        noDataLabel.isHidden = true
        
        state ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func didChangeFilter(_ filter: ArticleListViewModel.ArticleListFilter) {
        viewModel.refresh()
    }
    
    private func didChangeQuery(_ query: String) {
        viewModel.search(query: query)
    }
    
    @objc
    private func didChangeRefreshControl() {
        viewModel.refresh { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc
    private func didTapFavorite() {
        viewModel.filter = viewModel.filter == .favorites ? .all : .favorites
        configureNavigateionBar()
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let viewModel = viewModel.item(at: indexPath) {
            delegate?.didSelectArticle(viewModel.article)
        }
    }
}

extension ArticleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.items.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleListItemViewCell.identifier, for: indexPath) as? ArticleListItemViewCell else {
            fatalError("Unable to dequeue \(ArticleListItemViewCell.identifier)")
        }
        
        if let viewModel = viewModel.item(at: indexPath) {
            cell.update(for: viewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            viewModel.loadNext()
        }
    }
}

extension ArticleListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.refresh()
    }
}

extension ArticleListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        viewModel.query = query
    }
}

extension ArticleListViewController {
    static func instantiate(viewModel: ArticleListViewModel) -> ArticleListViewController {
        ArticleListViewController(viewModel: viewModel, nibName: "ArticleListViewController", bundle: nil)
    }
}
