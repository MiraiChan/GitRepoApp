//
//  RepositoryListViewModel.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import Foundation
import UIKit

enum ViewState {
  case loading
  case loaded
  case error(String)
}

final class RepositoryListViewModel {
  
  private let service: GitHubServiceProtocol
  private(set) var repositories: [Repository] = []
  private(set) var commits: [String: Commit] = [:]
  
  
  // MARK: - Loading state for commits
  // Tracks which repositories are currently fetching their last commit
  private(set) var loadingCommits: Set<String> = []
  
  // For demo purposes ViewModel notifies the UI with specific IndexPaths so the controller can reload only affected rows.
  // In production, especially for large datasets or frequent updates,
  // a more modern approach like UITableViewDiffableDataSource would be preferred.
  // That would eliminate manual IndexPath management and reduce potential UI flickering.
  var onUpdate: (([IndexPath]?, ViewState) -> Void)?
  
  init(service: GitHubServiceProtocol) {
    self.service = service
  }
  
  // MARK: - Data Loading
  // Task 1: Fetch the list of repositories
  // This updates the `repositories` array and notifies the UI.
  // Note: Pagination is not implemented for this task, but in a production app,
  // I would support scrolling to load more (e.g., using `page` parameter).
  func loadRepositories() {
    onUpdate?(nil, .loading)
    
    service.fetchRepositories { [weak self] result in
      switch result {
      case .success(let repos):
        self?.repositories = repos
        self?.onUpdate?(nil, .loaded)
        // Automatically start fetching commits after the list is loaded
        self?.loadCommits()
      case .failure(let error):
        self?.onUpdate?(nil, .error(error.localizedDescription))
      }
    }
  }
  
  // MARK: - Task 2: Async Commit Fetching
  // Iterates through all repositories and triggers a background fetch for the last commit.
  // Updates specific rows via IndexPath to avoid reloading the entire table.
  private func loadCommits() {
    for (index, repo) in repositories.enumerated() {
      // print("Fetching last commit for \(repo.name)")
      // mark as loading
      loadingCommits.insert(repo.name)
      
      service.fetchLastCommit(for: repo.name) { [weak self] result in
        guard let self = self else { return }
        
        switch result {
        case .success(let commit):
          // print("Commit for \(repo.name): \(commit?.message ?? "nil")")
          self.commits[repo.name] = commit
        case .failure:
          // print("Failed to fetch commit for \(repo.name)")
          self.commits[repo.name] = nil // could also track errors separately
        }
        
        // remove from loading set
        self.loadingCommits.remove(repo.name)
        
        // reload only the affected row
        let indexPath = IndexPath(row: index, section: 0)
        self.onUpdate?([indexPath], .loaded)
      }
    }
  }
}
