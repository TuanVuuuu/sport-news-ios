import Foundation

enum FootballEndpoint: APIEndpoint {
    case getFixtures(leagueId: Int)
    
    var path: String {
        switch self {
        case .getFixtures:
            return "api/football/fixtures"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getFixtures:
            return .get
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getFixtures(let leagueId):
            return ["league_id": leagueId]
        }
    }
    
    var bodyParameters: [String: Any]? {
        nil
    }
}
