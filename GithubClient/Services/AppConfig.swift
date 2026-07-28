//
//  AppConfig.swift
//  GithubClient
//
//  Created by Usuario invitado on 14/7/26.
//

import Foundation

enum AppConfig {
    private static let filename = "config"

    private enum Keys {
        static let apiBaseUrl = "API_BASE_URL"
        static let apiToken = "API_TOKEN"
    }

    private static var config: [String: Any] {
        guard
            let url = Bundle.main.url(
                forResource: filename, withExtension: "plist"
            ),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ),
            let dict = plist as? [String: Any]

        else {
            fatalError("Unable to load \(filename).plist")

        }

        return dict
    }

    static var apiBaseUrl: String {
        guard let url = config[Keys.apiBaseUrl] as? String else {
            fatalError("No se pudo obtener la URL base de la api")
        }
        return url
    }

    static var apiToken: String {
        guard let token = config[Keys.apiToken] as? String else {
            fatalError("No se pudo obtener el token de la api")
        }
        return token
    }
}
