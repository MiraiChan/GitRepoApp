//
//  GitHubService.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import Foundation

protocol GitHubServiceProtocol {
  func fetchRepositories(
    completion: @escaping (Result<[Repository], Error>) -> Void
  )
  
  func fetchLastCommit(
    for repo: String,
    completion: @escaping (Result<Commit?, Error>) -> Void
  )
}

final class GitHubService: GitHubServiceProtocol {
  
  private let apiClient: APIClientProtocol
  private let user: String
  
  init(apiClient: APIClientProtocol, user: String = "mralexgray") {
    self.apiClient = apiClient
    self.user = user
  }
  
  // MARK: - Task 1: Connect to the Github API
  // Retrieves the list of public repositories for the specified user.
  func fetchRepositories(
    completion: @escaping (Result<[Repository], Error>) -> Void
  ) {
    apiClient.request(.repositories(user: user)) { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }
  }
  
  // MARK: - Task 2: Asynchronously load the last commit
  // Fetches the last commit for a specific repository.
  // This is called lazily as the list is populated/scrolled.
  func fetchLastCommit(
    for repo: String,
    completion: @escaping (Result<Commit?, Error>) -> Void
  ) {
    apiClient.request(.commits(user: user, repo: repo)) { (result: Result<[CommitResponse], Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success(let responses):
          let commit = responses.first?.commit
          completion(.success(commit))
          
        case .failure(let error):
          //print("Failed to fetch commits for \(repo):", error)
          completion(.failure(error))
        }
      }
    }
  }
}
