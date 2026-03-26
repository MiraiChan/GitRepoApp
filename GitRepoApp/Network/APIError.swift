//
//  APIError.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//
import Foundation

enum APIError: LocalizedError {
  case invalidURL
  case noData
  case invalidResponse(statusCode: Int)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .noData:
      return "No data received"
    case .invalidResponse(let statusCode):
      return "Invalid response with status code: \(statusCode)"
    }
  }
}
