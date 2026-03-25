import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firebaseUid: String
    let email: String
    let displayName: String?
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case firebaseUid
        case email
        case displayName
        case avatarUrl
        case createdAt
        case updatedAt
    }
}
