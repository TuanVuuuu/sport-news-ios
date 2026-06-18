import Foundation

struct FootballTeam: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let nameFull: String
    let logoUrl: String
}

struct FootballFixture: Identifiable, Equatable, Hashable {
    let id: Int
    let kickoffDate: Date?
    let kickoffTime: String
    let homeTeam: FootballTeam
    let awayTeam: FootballTeam
    let homeScore: Int
    let awayScore: Int
    let statusShort: String
    let statusLabel: String
    let roundLabel: String
    let groupLabel: String
    let venue: String
    
    var localizedKickoffTime: String {
        kickoffDate?.fixtureTimeString() ?? kickoffTime
    }
    
    var isFinished: Bool {
        statusShort == "FT"
    }
    
    var isUpcoming: Bool {
        statusShort == "NS"
    }
    
    var isKickoffInFuture: Bool {
        guard let kickoffDate else { return isUpcoming }
        return kickoffDate > Date()
    }
    
    var scoreText: String? {
        guard isFinished || statusShort == "LIVE" || statusShort == "HT" else {
            return nil
        }
        return "\(homeScore) - \(awayScore)"
    }
}

struct FixtureScheduleDay: Identifiable, Equatable, Hashable {
    let id: String
    let date: String
    let dateLabel: String
    let weekdayLabel: String
    let matches: [FootballFixture]
}

struct WorldCupSchedule: Equatable, Hashable {
    let leagueName: String
    let leagueLogoUrl: String
    let timezoneNote: String
    let totalMatches: Int
    let scheduleDays: [FixtureScheduleDay]
    
    /// Ngày gần nhất còn trận sắp diễn ra. Trả về nil nếu không còn trận nào.
    func nearestUpcomingDay() -> FixtureScheduleDay? {
        let upcomingMatches = scheduleDays
            .flatMap(\.matches)
            .filter { $0.isUpcoming && $0.isKickoffInFuture }
        
        guard let earliestMatch = upcomingMatches.min(by: {
            ($0.kickoffDate ?? .distantFuture) < ($1.kickoffDate ?? .distantFuture)
        }) else {
            return nil
        }
        
        return scheduleDays.first { day in
            day.matches.contains { $0.id == earliestMatch.id }
        }
    }
    
    func defaultSelectedDayIndex() -> Int {
        guard !scheduleDays.isEmpty else { return 0 }
        
        if let upcomingDay = nearestUpcomingDay(),
           let index = scheduleDays.firstIndex(where: { $0.id == upcomingDay.id }) {
            return index
        }
        
        let calendar = Calendar.current
        if let todayIndex = scheduleDays.firstIndex(where: { day in
            day.matches.contains { match in
                guard let kickoffDate = match.kickoffDate else { return false }
                return calendar.isDateInToday(kickoffDate)
            }
        }) {
            return todayIndex
        }
        
        return scheduleDays.count - 1
    }
}
