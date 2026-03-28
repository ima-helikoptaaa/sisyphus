import Foundation

extension Notification.Name {
    static let unauthorizedResponse = Notification.Name("unauthorizedResponse")
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case noToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, let message):
            return message ?? "HTTP Error \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return error.localizedDescription
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .noToken:
            return "No authentication token available."
        }
    }
}

struct APIErrorResponse: Codable {
    let error: String?
    let message: String?
}

final class APIService {
    static let shared = APIService()

    private static let defaultBaseURL = "http://13.214.26.96/api/sisyphus"

    private var baseURL: String {
        UserDefaults.standard.string(forKey: "api_base_url") ?? Self.defaultBaseURL
    }

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]
        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
        dateOnlyFormatter.timeZone = TimeZone(identifier: "UTC")
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }
            if let date = dateOnlyFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private init() {}

    private func getToken() async throws -> String {
        guard let token = await AuthService.shared.getIDToken() else {
            throw APIError.noToken
        }
        return token
    }

    private func buildRequest(path: String, method: String, body: Data? = nil) async throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try await getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            await MainActor.run {
                NotificationCenter.default.post(name: .unauthorizedResponse, object: nil)
            }
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.error ?? errorResponse?.message
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("⚠️ Decoding error for \(T.self): \(error)")
            print("⚠️ Raw response: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw APIError.decodingError(error)
        }
    }

    private func performRequestNoContent(_ request: URLRequest) async throws {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            await MainActor.run {
                NotificationCenter.default.post(name: .unauthorizedResponse, object: nil)
            }
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.error ?? errorResponse?.message
            )
        }
    }

    func get<T: Decodable>(path: String) async throws -> T {
        let request = try await buildRequest(path: path, method: "GET")
        return try await performRequest(request)
    }

    func post<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try await buildRequest(path: path, method: "POST", body: bodyData)
        return try await performRequest(request)
    }

    func patch<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try await buildRequest(path: path, method: "PATCH", body: bodyData)
        return try await performRequest(request)
    }

    func patch<T: Decodable>(path: String) async throws -> T {
        let request = try await buildRequest(path: path, method: "PATCH")
        return try await performRequest(request)
    }

    func put<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        let bodyData = try encoder.encode(body)
        let request = try await buildRequest(path: path, method: "PUT", body: bodyData)
        return try await performRequest(request)
    }

    func delete(path: String) async throws {
        let request = try await buildRequest(path: path, method: "DELETE")
        try await performRequestNoContent(request)
    }

    func post<B: Encodable>(path: String, body: B) async throws {
        let bodyData = try encoder.encode(body)
        let request = try await buildRequest(path: path, method: "POST", body: bodyData)
        try await performRequestNoContent(request)
    }
}
