import Foundation

protocol GetWorldCupFixturesUseCaseProtocol {
    func execute(leagueId: Int) async throws -> WorldCupSchedule
}

final class GetWorldCupFixturesUseCase: GetWorldCupFixturesUseCaseProtocol {
    private let repository: FootballRepositoryProtocol
    
    init(repository: FootballRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(leagueId: Int = 1) async throws -> WorldCupSchedule {
        try await repository.getWorldCupFixtures(leagueId: leagueId)
    }
}
