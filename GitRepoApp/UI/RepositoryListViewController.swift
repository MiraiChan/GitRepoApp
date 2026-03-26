//
//  RepositoryListViewController.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import UIKit

final class RepositoryListViewController: UIViewController {
  
  private let tableView = UITableView()
  private let viewModel: RepositoryListViewModel
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let refreshControl = UIRefreshControl()
  
  init(viewModel: RepositoryListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  // or fatalError("init(coder:) is not implemented because this view is programmatic")
  required init?(coder: NSCoder) {
    return nil
  }
  
  // MARK: - Lifecycle
  // Task 3: Build some custom UI
  // This controller uses a programmatic UI approach (no Storyboards/XIBs).
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
    // Trigger initial data load
    viewModel.loadRepositories()
  }
  
  private func setupUI() {
    title = "Repositories"
    view.backgroundColor = .systemBackground
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(RepositoryCell.self,
                       forCellReuseIdentifier: RepositoryCell.identifier)
    tableView.dataSource = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 150
    
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    tableView.refreshControl = refreshControl
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    view.addSubview(activityIndicator)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  @objc private func refreshData() {
    viewModel.loadRepositories()
  }
  
  private func bindViewModel() {
    viewModel.onUpdate = { [weak self] indexPaths, state in
      guard let self = self else { return }
      switch state {
      case .loading:
        self.activityIndicator.startAnimating()
      case .loaded:
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
        if let indexPaths = indexPaths {
          self.tableView.reloadRows(at: indexPaths, with: .automatic)
        } else {
          self.tableView.reloadData()
        }
      case .error(let message):
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
        self.showError(message)
      }
    }
  }
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error",
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

extension RepositoryListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.repositories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: RepositoryCell.identifier,
      for: indexPath
    ) as? RepositoryCell else {
      return UITableViewCell()
    }
    
    let repo = viewModel.repositories[indexPath.row]
    let commit = viewModel.commits[repo.name]
    // I use loadingCommits to track which repositories are currently fetching their last commit.
    // This helps the UI distinguish the states:
    // - Commit is still loading → show spinner
    // - Loading failed → we stop spinner but commit == nil
    // - Repository has no commits → commit == nil, but spinner is not shown
    //
    // Before, I was using `let isLoadingCommit = (commit == nil)`
    // but that could not differentiate these three cases.
    // Now I use the Set<String> in the ViewModel to explicitly track loading state:
    let isLoadingCommit = viewModel.loadingCommits.contains(repo.name)
    
    // Configure the cell with the commit and loading state
    cell.configure(with: repo, commit: commit, isLoadingCommit: isLoadingCommit)
    return cell
  }
}
