# Cliente de GitHub para iOS (SwiftUI + Alamofire)

## Propósito

Este README contiene las instrucciones necesarias para desarrollar la versión iOS de la aplicación cliente de GitHub. Se enfoca en SwiftUI, arquitectura recomendada (MVVM), y en el uso de Alamofire para consumir la API REST de GitHub. Los laboratorios 10, 11 y 12 están orientados a UI (listas, formularios, inputs y botones) y a integrar llamadas HTTP (GET y POST).

## Datos del estudiante.

- Nombre del Estudiante: Andres Criollo
- Carrera / Nivel; Desarrollo de Software

---

## Requisitos mínimos

- macOS con Xcode 16 o superior
- Xcode (última versión estable recomendada)
- Swift 5.7+ (según la versión de Xcode)
- Swift Package Manager (integrado en Xcode) o CocoaPods (opcional)
- Token de acceso personal de GitHub (GITHUB_TOKEN)

---

## Estructura recomendada del proyecto

- Modelo: `Models/` (structs que representan Repositorio, Usuario, etc.)
- Vistas: `Views/` (SwiftUI Views: lista, item, formulario, detalle)
- ViewModels: `ViewModels/` (observable objects que manejan estados y llamadas a la API)
- Servicios: `Services/` (API Client que usa Alamofire)
- Recursos: `Resources/` (Assets, constantes)

Se recomienda usar MVVM: las Views observan a ViewModels que exponen @Published para estado, listas y errores.

---

## Integración de Alamofire

Recomendado: usar Swift Package Manager (SPM) desde Xcode:

1. En Xcode: File > Add Packages...
2. Pegar URL: `https://github.com/Alamofire/Alamofire.git`
3. Seleccionar la versión estable (p. ej. ~> 5.6)

Alternativa con CocoaPods:

1. Crear `Podfile` en el directorio del proyecto y añadir:

```
platform :ios, '15.0'
use_frameworks!

target 'NombreDelTarget' do
  pod 'Alamofire', '~> 5.6'
end
```

2. Ejecutar `pod install` y abrir el `.xcworkspace`.

---

## Configuración del token (GITHUB_TOKEN)

No incluyas el token en el código fuente. Opciones seguras para desarrollo local:

- Añadir como variable de entorno en el esquema de Xcode: Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables -> `GITHUB_TOKEN` = `<tu_token>`
- Usar un archivo `.env` local que esté en `.gitignore` (no recomendado para producción)

En código Swift puedes leerlo desde las variables de entorno del proceso:

```swift
let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""
```

En el cliente de Alamofire se usarán cabeceras:

```swift
import Alamofire

let headers: HTTPHeaders = [
  "Authorization": "token \(token)",
  "Accept": "application/vnd.github.v3+json"
]
```

---

## Endpoints principales (ejemplos)

- GET https://api.github.com/user — información del usuario
- GET https://api.github.com/user/repos — lista de repositorios del usuario
- POST https://api.github.com/user/repos — crear un nuevo repositorio
- PATCH https://api.github.com/repos/{owner}/{repo} — actualizar repositorio
- DELETE https://api.github.com/repos/{owner}/{repo} — eliminar repositorio

---

## Ejemplos de uso de Alamofire (Swift)

1. GET — Obtener repositorios

```swift
import Alamofire

class GithubService {
    static let shared = GithubService()

    private var token: String { ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? "" }

    private var baseHeaders: HTTPHeaders {
        [
            "Authorization": "token \(token)",
            "Accept": "application/vnd.github.v3+json"
        ]
    }

    func fetchUserRepos(completion: @escaping (Result<[Repository], AFError>) -> Void) {
        AF.request("https://api.github.com/user/repos", headers: baseHeaders)
            .validate()
            .responseDecodable(of: [Repository].self) { response in
                completion(response.result)
            }
    }
}
```

2. POST — Crear repositorio

```swift
func createRepo(name: String, description: String?, isPrivate: Bool, completion: @escaping (Result<Repository, AFError>) -> Void) {
    let params: [String: Any] = [
        "name": name,
        "description": description ?? "",
        "private": isPrivate
    ]

    AF.request("https://api.github.com/user/repos", method: .post, parameters: params, encoding: JSONEncoding.default, headers: baseHeaders)
        .validate()
        .responseDecodable(of: Repository.self) { response in
            completion(response.result)
        }
}
```

Ajusta los modelos `Repository` y `User` para conformar `Decodable`.

---

## Laboratorio 10.- Diseño de UI con SwiftUI

Recomendación con SwiftUI:

- Lista de repositorios: usar `List` con una fila reutilizable `RepoRow`.

```swift
List(viewModel.repos) { repo in
    RepoRow(repo: repo)
}
```

- Componente de ítem de repositorio: `RepoRow` (muestra nombre, descripción y botones de acción si aplica).
- Formulario de creación: usar `Form` o `VStack` con `TextField`, `TextEditor` y `Button`.

Ejemplo de formulario mínimo:

```swift
Form {
  TextField("Nombre del repo", text: $name)
  TextEditor(text: $description)
  Toggle("Privado", isOn: $isPrivate)
  Button("Crear") { viewModel.createRepo(...) }
}
```

- Manejo de estados: ViewModel con @Published var isLoading, var error: String?, var repos: [Repository]
- Feedback visual: `ProgressView` para cargas, `Alert` para errores/confirmaciones

---

## Laboratorio 11 — Integración: métodos GET (Obtener datos)

Objetivo:

- Implementar y probar las llamadas GET a la API de GitHub para obtener la lista de repositorios del usuario y la información del usuario.
- Integrar estas llamadas con la UI (listas y vistas de detalle) usando ViewModels.

Tareas clave:

- Implementar en `GithubService` métodos como `fetchUserRepos(completion:)` y `fetchUser(completion:)` usando Alamofire.
- Manejar estados de carga y errores en el ViewModel (`isLoading`, `errorMessage`).
- Mostrar `ProgressView` mientras se cargan datos y refrescar la `List` cuando los datos estén disponibles.
- Soportar recarga manual (pull to refresh) y reintentos en caso de error.

Ejemplo breve de método GET adicional (obtener usuario):

```swift
func fetchUser(completion: @escaping (Result<User, AFError>) -> Void) {
    AF.request("https://api.github.com/user", headers: baseHeaders)
      .validate()
      .responseDecodable(of: User.self) { response in
          completion(response.result)
      }
}
```

ViewModel (uso típico en Lab 11):

```swift
class ReposViewModel: ObservableObject {
  @Published var repos: [Repository] = []
  @Published var user: User? = nil
  @Published var isLoading = false
  @Published var errorMessage: String? = nil

  func load() {
    isLoading = true
    let group = DispatchGroup()

    group.enter()
    GithubService.shared.fetchUserRepos { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .success(let repos): self?.repos = repos
        case .failure(let err): self?.errorMessage = err.localizedDescription
        }
        group.leave()
      }
    }

    group.enter()
    GithubService.shared.fetchUser { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .success(let user): self?.user = user
        case .failure: break
        }
        group.leave()
      }
    }

    group.notify(queue: .main) { [weak self] in
      self?.isLoading = false
    }
  }
}
```

Notas:

- Maneja paginación si el endpoint devuelve muchas páginas (usar parámetros `?page=` y `?per_page=`).
- Loguea respuestas y códigos HTTP durante desarrollo para depuración.

---

## Laboratorio 12 — Integración: métodos POST (Crear recursos)

Objetivo:

- Implementar la funcionalidad de creación de repositorios (POST) y cualquier operación que requiera enviar datos (por ejemplo, editar via PATCH en ejercicios siguientes).
- Validar formularios en la UI antes de enviar la petición.
- Actualizar la UI tras una creación exitosa (insertar el nuevo repo en la lista o recargar los datos).

Tareas clave:

- Implementar en `GithubService` el método `createRepo(name:description:private:completion:)` usando `JSONEncoding.default`.
- En la vista de formulario, validar campos (p. ej. nombre no vacío). Mostrar errores de validación locales antes de llamar a la API.
- Mostrar estados: deshabilitar el botón de envío mientras `isLoading == true`, y usar `ProgressView` o un indicador en el botón.
- Manejar respuestas de error y mostrar `Alert` con el mensaje de GitHub cuando sea posible.

Ejemplo de método POST (ya incluido en el README, pero resumido):

```swift
func createRepo(name: String, description: String?, isPrivate: Bool, completion: @escaping (Result<Repository, AFError>) -> Void) {
    let params: [String: Any] = [
        "name": name,
        "description": description ?? "",
        "private": isPrivate
    ]

    AF.request("https://api.github.com/user/repos", method: .post, parameters: params, encoding: JSONEncoding.default, headers: baseHeaders)
      .validate()
      .responseDecodable(of: Repository.self) { response in
          completion(response.result)
      }
}
```

Ejemplo de flujo en ViewModel para creación:

```swift
func createRepo(name: String, description: String?, isPrivate: Bool) {
  guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    self.errorMessage = "El nombre del repositorio no puede estar vacío"
    return
  }
  isLoading = true
  GithubService.shared.createRepo(name: name, description: description, isPrivate: isPrivate) { [weak self] result in
    DispatchQueue.main.async {
      self?.isLoading = false
      switch result {
      case .success(let repo):
        // Insertar al inicio o recargar la lista
        self?.repos.insert(repo, at: 0)
      case .failure(let err):
        self?.errorMessage = err.localizedDescription
      }
    }
  }
}
```

Notas:

- Maneja correctamente códigos 201 (creado) y errores 4xx/5xx mostrando mensajes útiles.
- Para pruebas, crea una cuenta de GitHub de pruebas o usa repos privados controlados para evitar afectar proyectos reales.

---

## Integración UI/Networking — recomendaciones generales

- Separar claramente responsabilidades: Views sólo presentan UI; ViewModels gestionan estado; Services manejan red.
- Inyecta dependencias (por ejemplo, un `NetworkClient` protocol) para facilitar mocking en tests.
- Mantén la UI responsiva: evita bloquear el hilo principal y actualiza UI en DispatchQueue.main.

---

## Pruebas locales y Mocking

- Para pruebas de UI y desarrollo offline, crea un cliente de red que pueda inyectar respuestas mock (protocolos + implementaciones de testing).
- También puedes usar ficheros JSON locales en el bundle y decodificarlos durante desarrollo.

---

## Ejecutar en el simulador o dispositivo

- Abrir proyecto en Xcode.
- Seleccionar un esquema/simulator y ejecutar (Cmd+R).
- Para pruebas en dispositivo real, configurar provisioning profiles y firmar la app.

---

## Git y buenas prácticas

- Añadir `readme.md` y código fuente al control de versiones.
- Nunca subir tokens ni archivos con secrets al repositorio.
- Añadir `.gitignore` para `xcuserdata`, `Pods/`, `DerivedData`, y archivos locales de configuración.

---

## Mapeo de entregables por laboratorio

- Laboratorio 10 (UI): Implementar interfaz de lista, componente de item, formulario de creación básico y pantalla de usuario.
- Laboratorio 11 (GET): Integrar Alamofire, obtener lista de repos y datos del usuario; manejar carga y errores.
- Laboratorio 12 (POST): Implementar formulario validado para crear repositorios; manejar respuesta y actualizar la lista.

---

## Recursos

- Alamofire: https://github.com/Alamofire/Alamofire
- GitHub REST API: https://docs.github.com/en/rest
- SwiftUI: https://developer.apple.com/documentation/swiftui

---

## Contacto

- Docente: Pablo Pérez Martínez — paperez@puce.edu.ec
