import Foundation

protocol FootballRepositoryProtocol {
    func getWorldCupFixtures(leagueId: Int) async throws -> WorldCupSchedule
}
