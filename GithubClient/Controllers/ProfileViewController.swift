//
//  ProfileViewController.swift
//  GithubClient
//
//  Created by Usuario invitado on 28/7/26.
//

import Foundation

@MainActor
class ProfileViewController: ObservableObject {
    @Published var userInfo: UserInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMsg: String?

    private let githubService: GithubService

    init(service: GithubService = .shared) {
        self.githubService = service
    }

    func loadUser() async {
        isLoading = true
        do {
            self.userInfo = try await githubService.getUser()
        } catch {
            print(error)
            errorMsg = error.localizedDescription
        }
        isLoading = false
    }
}
