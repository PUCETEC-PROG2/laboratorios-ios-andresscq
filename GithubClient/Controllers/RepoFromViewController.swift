//
//  RepoFormViewController.swift
//  GithubClient
//

//

import Foundation

@MainActor
class RepoFormViewController: ObservableObject {
    @Published var repoName : String = ""
    @Published var repoDescription : String = ""
    @Published var repository : Repository? = nil
    @Published var isLoading: Bool = false
    @Published var errorMsg: String?
    
    private let githubService: GithubService
    
    init(service: GithubService = .shared) {
        self.githubService = service
    }
    
    func createRepository () async {
        isLoading = true
        do {
            self.repository = try await githubService.createRepository(name: repoName, desc: repoDescription)
            self.repoName = ""
            self.repoDescription = ""
        } catch {
            errorMsg = error.localizedDescription
        }
        isLoading = false
    }
}
