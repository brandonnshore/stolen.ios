import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let role: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, name, role
        case createdAt
        case updatedAt
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}
