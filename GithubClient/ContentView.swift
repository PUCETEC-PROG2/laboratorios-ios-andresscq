//
//  ContentView.swift
//  GithubClient
//

//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0;
    
    var body: some View {
        TabView (selection: $selectedTab){
            RepoList()
                .tabItem {
                    Label("Repositorios",
                          systemImage: "arrow.trianglehead.branch")
                }
                .tag(0)
            RepoForm(selectTab: $selectedTab)
                .tabItem {
                    Label("Crear Repositorio",
                          systemImage: "plus")
                }
                .tag(1)
            Profile()
                .tabItem {
                    Label("Perfil de usuario",
                          systemImage: "person.crop.circle")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
