import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
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
        
        // 🔥 LOG REQUEST ĐI ĐI
        logRequest(request)
        
        // 2. Thực thi Request
        let (data, response) = try await session.data(for: request)
        
        // 🔥 LOG RESPONSE ĐỔ VỀ
        logResponse(response, data: data)
        
        // 3. Decode dữ liệu
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Helper Logging Functions
    
    private func logRequest(_ request: URLRequest) {
        print("\n🌐 >>>>>>>>>> OUTGOING REQUEST >>>>>>>>>>")
        print("🔗 URL: \(request.url?.absoluteString ?? "")")
        print("📝 METHOD: \(request.httpMethod ?? "")")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("🔑 HEADERS: \(headers)")
        }
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📦 BODY: \(bodyString)")
        }
        print("-----------------------------------------\n")
    }
    
    private func logResponse(_ response: URLResponse, data: Data) {
        print("\n📥 <<<<<<<<<< INCOMING RESPONSE <<<<<<<<<<")
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            // Đánh dấu icon theo Status Code để dễ nhìn bằng mắt
            let statusIcon = (200...299).contains(statusCode) ? "🟢" : "🔴"
            print("\(statusIcon) STATUS CODE: \(statusCode)")
        }
        
        // Đọc và format JSON Response cho đẹp, dễ nhìn (Pretty Print)
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("📄 JSON BODY:\n\(prettyString)")
        } else if let plainString = String(data: data, encoding: .utf8) {
            print("📄 RAW BODY: \(plainString)")
        }
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n")
    }
}
