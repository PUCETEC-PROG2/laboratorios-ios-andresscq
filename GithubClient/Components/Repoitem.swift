//
//  Repoitem.swift
//  GithubClient
//

//

import SwiftUI

struct Repoitem: View {
    let repository: Repository
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: repository.owner.avatarUrl)!) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(uiImage: .githubLogo)
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 80, height: 80)
            .padding(.trailing, 8)
            
            VStack (alignment: .leading) {
                Text(repository.name)
                    .font(.title2)
                
                if let description = repository.description {
                    Text(description)
                        .font(.caption)
                }
                
                if let language = repository.language{
                    HStack {
                        Text("Lenguaje")
                            .font(.caption)
                        Spacer()
                        Text(language)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    Repoitem(
        repository: Repository (
            id: 1,
            name: "Ejemplo REPO",
            description: "texto de relleno de las imprentas y archivos de texto.",
            language: "Swift",
            owner: UserInfo(
                login: "stevenjacomeyandun",
                name: "Steven Jácome Yandún",
                avatarUrl: "",
                bio: "Esta es una Bio de prueba"
            )
        )
    )
}
