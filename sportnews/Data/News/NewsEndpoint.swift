import Foundation

enum NewsEndpoint: APIEndpoint {
    case getNews(category: String, page: Int, limit: Int)
    case getCategories(type: String)
    
    var path: String {
        switch self {
        case .getNews:
            return "api/news"
            
        case .getCategories:
            return "api/categories"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
            
            
        case .getCategories:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getNews(let category, let page, let limit):
            return [
                "category": category,
                "page": page,
                "limit": limit
            ]
            
            
        case .getCategories(let type):
            return ["type": type]
        }
    }
    
    var bodyParameters: [String : Any]? {
        return nil
    }
    
}
