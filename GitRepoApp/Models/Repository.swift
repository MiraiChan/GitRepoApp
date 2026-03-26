//
//  Repository.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import Foundation

struct Repository: Decodable {
  let name: String
  let description: String?
  let stargazersCount: Int?
  let language: String?
}
