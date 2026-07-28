//
//  Profile.swift
//  GithubClient
//
//  Created by Usuario invitado on 7/7/26.
//

import SwiftUI

struct Profile: View {
    @StateObject private var viewController = ProfileViewController()

    var body: some View {
        NavigationStack {
            Group {
                if viewController.isLoading {
                    ProgressView("Cargando perfil...")
                } else if let errorMsg = viewController.errorMsg {
                    Text(errorMsg)
                        .foregroundStyle(.red)
                        .padding()
                } else if let user = viewController.userInfo {
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: user.avatarUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(uiImage: .githubLogo)
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())

                        Text(user.name ?? user.login)
                            .font(.title2)
                            .bold()

                        Text("@\(user.login)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let bio = user.bio {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Perfil de usuario")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await viewController.loadUser()
            }
        }
    }
}

#Preview {
    Profile()
}
