import Foundation

enum NewsEndpoint: APIEndpoint {
    case getNews(category: String, page: Int, limit: Int)
    case getCategories(type: String)
    case getDiscover
    
    var path: String {
        switch self {
        case .getNews:
            return "api/news"
            
        case .getCategories:
            return "api/categories"
            
        case .getDiscover:
            return "api/discover"
        }
        
        
    }
    
    var method: HTTPMethod {
        switch self {
        case .getNews:
            return .get
            
            
        case .getCategories:
            return .get
            
        case .getDiscover:
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
            
        case .getDiscover:
            return nil
        }
        
        
    }
    
    var bodyParameters: [String : Any]? {
        return nil
    }
    
}
