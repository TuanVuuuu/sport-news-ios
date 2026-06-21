import Foundation
import Pulse

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = NetworkSessionProvider.shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // 1. Tạo URLRequest từ endpoint
        guard var urlComponents = URLComponents(string: endpoint.baseURL + "/" + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        if let queryParams = endpoint.queryParameters {
            urlComponents.queryItems = queryParams.map { key, value in
                // Chuyển đổi mọi giá trị (Int, String, Bool) thành chuỗi String để URLQueryItem nhận diện
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.bodyParameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        _ = response

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
