import Foundation //

enum HTTPMethod: String {
    case get            = "GET"
    case post           = "POST"
    case put            = "PUT"
    case delete         = "DELETE"
}

protocol APIEndpoint {
    var baseURL:            String { get }
    var path:               String { get }
    var method:             HTTPMethod { get }
    var headers:            [String: String]? { get }
    var queryParameters:    [String: Any]? { get }
    var bodyParameters:     [String: Any]? { get }
}

extension APIEndpoint {
    var baseURL: String {
        return "https://vn-sport-news-i1l7.onrender.com"
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}



