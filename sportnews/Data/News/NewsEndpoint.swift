import Foundation

enum NewsEndpoint: APIEndpoint {
    case getNews(category: String, page: Int, limit: Int)
    case getCategories(type: String)
    case getDiscover
    case getSuggestions(limit: Int)
    case getNewsSearch(page: Int, size: Int, text: String)
    case getNewsByIds(ids: [String], category: String)
    
    var path: String {
        switch self {
        case .getNews:
            return "api/news"
            
        case .getCategories:
            return "api/categories"
            
        case .getDiscover:
            return "api/discover"
            
        case .getSuggestions:
            return "api/search/suggestions"
            
        case .getNewsSearch:
            return "api/news/search"

        case .getNewsByIds:
            return "api/news/by-ids"
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
            
        case .getSuggestions:
            return .get
            
        case .getNewsSearch:
            return .get

        case .getNewsByIds:
            return .post
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
            
        case .getSuggestions(let limit):
            return [
                "limit": limit
            ]
            
        case .getNewsSearch(let page, let size, let text):
            return [
                "page": page,
                "size": size,
                "text": text
            ]

        case .getNewsByIds:
            return nil
        }
    }
    
    var bodyParameters: [String : Any]? {
        switch self {
        case .getNewsByIds(let ids, let category):
            return [
                "ids": ids,
                "category": category
            ]
        default:
            return nil
        }
    }
    
}
