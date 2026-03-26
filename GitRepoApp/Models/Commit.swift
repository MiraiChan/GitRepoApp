//
//  Commit.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//
import Foundation

struct CommitResponse: Decodable {
  let commit: Commit
}

struct Commit: Decodable {
  let message: String
}
