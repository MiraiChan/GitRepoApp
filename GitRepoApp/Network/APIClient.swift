//
//  APIClient.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import Foundation

protocol APIClientProtocol {
  func request<T: Decodable>(
    _ endpoint: Endpoint,
    completion: @escaping (Result<T, Error>) -> Void
  )
}

final class APIClient: APIClientProtocol {
  
  private let session: URLSession
  private let decoder: JSONDecoder
  
  init(session: URLSession = .shared) {
    self.session = session
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
  }
  
  func request<T: Decodable>(
    _ endpoint: Endpoint,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    guard let url = endpoint.url else {
      completion(.failure(APIError.invalidURL))
      return
    }
    
    var request = URLRequest(url: url)
    request.setValue("GitHubTestApp", forHTTPHeaderField: "User-Agent")
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    
    // MARK: - Authentication
    // NOTE:
    // During development, I used a personal access token because I was hitting
    // a 403 rate limit from GitHub API (without a token, the limit is 60 requests/hour).
    //
    // For demo purposes, no token is included in this project.
    // If you encounter the same 403 error, you can:
    // 1) Add a personal access token locally (do NOT commit it to version control)
    // 2) Or reduce the number of commit requests (e.g., load only visible cells)
    //
    // Example of adding a token locally (not committed):
    //
    // let token = "<YOUR_PERSONAL_ACCESS_TOKEN>"
    // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //
    // In production, tokens should always be:
    // - Stored securely (e.g., in Keychain)
    // - Injected via configuration or environment variables
    // - Never hardcoded in source code
    
    let task = session.dataTask(with: request) { data, response, error in
      
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(APIError.noData))
        return
      }
      print("Status code:", httpResponse.statusCode)
      
      guard 200..<300 ~= httpResponse.statusCode else {
        completion(.failure(APIError.invalidResponse(statusCode: httpResponse.statusCode)))
        return
      }
      
      guard let data = data else {
        completion(.failure(APIError.noData))
        return
      }
      
      do {
        let decoded = try self.decoder.decode(T.self, from: data)
        completion(.success(decoded))
      } catch {
        let str = String(data: data, encoding: .utf8) ?? "<no data>"
        //print("Failed to decode JSON:", str)
        //print("Decoding error:", error)
        completion(.failure(error))
      }
    }
    task.resume()
  }
}
