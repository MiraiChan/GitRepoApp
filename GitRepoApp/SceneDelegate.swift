//
//  SceneDelegate.swift
//  GitRepoApp
//
//  Created by Almira Khafizova on 17.02.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let apiClient = APIClient()
    let service = GitHubService(apiClient: apiClient)
    let viewModel = RepositoryListViewModel(service: service)
    let rootVC = RepositoryListViewController(viewModel: viewModel)
    let nav = UINavigationController(rootViewController: rootVC)
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = nav
    window?.makeKeyAndVisible()
  }
}
