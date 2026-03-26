//
//  Endpoint.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import Foundation

enum Endpoint {
  case repositories(user: String)
  case commits(user: String, repo: String)
  
  var url: URL? {
    switch self {
    case .repositories(let user):
      //URL for fetching all public repositories of a user. Currently hardcoded in the service, but can be extracted to a constant for flexibility
      return URL(string: "https://api.github.com/users/\(user)/repos")
      
    case .commits(let user, let repo):
      // URL for fetching commits of a specific repository. Сan also be extracted to a constant for flexibility
      return URL(string: "https://api.github.com/repos/\(user)/\(repo)/commits")
    }
  }
}
