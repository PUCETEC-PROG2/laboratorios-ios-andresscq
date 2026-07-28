//
//  Repository.swift
//  GithubClient
//
//  Created by Usuario invitado on 14/7/26.
//

import Foundation

struct Repository: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String?
    let language: String?
    let owner: UserInfo
}

