//
//  RepoForm.swift
//  GithubClient
//

//

import Foundation
import SwiftUI

struct RepoForm: View {
    @StateObject private var viewController = RepoFormViewController()
    @Binding var selectTab: Int
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewController.isLoading {
                    ProgressView("Creando repositorio...")
                } else if let errorMsg = viewController.errorMsg {
                    Text(errorMsg)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    Spacer()
                    TextField(
                        "Nombre del repositorio",
                        text: $viewController.repoName
                    )
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical)
                    
                    TextField(
                        "Descripción del repositorio",
                        text: $viewController.repoDescription,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding(.vertical)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            print("Botón presionado")
                        }){
                            Label("Cancelar", systemImage: "xmark.circle")
                                .padding(.all, 4)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal, 4)
                        
                        Button(action: {
                            Task {
                                await viewController.createRepository()
                                if (viewController.errorMsg == nil) {
                                    selectTab = 0
                                }
                            }
                        }){
                            Label("Guardar", systemImage: "square.and.arrow.down")
                                .padding(.all, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 4)
                        .disabled(viewController.repoName == "")
                    }
                }
            }
            
            .padding()
            .navigationTitle("Formulario de repositorio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RepoForm(selectTab: .constant(1))
}
