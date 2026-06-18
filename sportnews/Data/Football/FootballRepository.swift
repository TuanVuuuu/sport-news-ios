import Foundation

final class FootballRepository: FootballRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getWorldCupFixtures(leagueId: Int) async throws -> WorldCupSchedule {
        let endpoint = FootballEndpoint.getFixtures(leagueId: leagueId)
        let response: GetFixturesResponseDTO = try await networkService.request(endpoint)
        return response.body?.data?.toDomain() ?? WorldCupSchedule(
            leagueName: "World Cup",
            leagueLogoUrl: "",
            timezoneNote: "",
            totalMatches: 0,
            scheduleDays: []
        )
    }
}
