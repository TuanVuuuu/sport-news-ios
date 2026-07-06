import Foundation

struct GetFixturesResponseDTO: Decodable {
    let status: Int
    let body: FixturesBodyDTO?
}

struct FixturesBodyDTO: Decodable {
    let data: FixturesDataDTO?
}

struct FixturesDataDTO: Decodable {
    let league: LeagueDTO?
    let timezone_note: String?
    let total_matches: Int?
    let schedule: [FixtureDayDTO]?
}

struct LeagueDTO: Decodable {
    let id: Int?
    let name: String?
    let logo: String?
    let country: String?
}

struct FixtureDayDTO: Decodable {
    let date: String?
    let date_label: String?
    let weekday_label: String?
    let matches: [FixtureMatchDTO]?
}

struct FixtureMatchDTO: Decodable {
    let fixture_id: Int?
    let kickoff_at: String?
    let kickoff_timestamp: Int?
    let kickoff_time: String?
    let home_team: FixtureTeamDTO?
    let away_team: FixtureTeamDTO?
    let score: FixtureScoreDTO?
    let status: String?
    let status_short: String?
    let round_label: String?
    let group_label: String?
    let venue: String?
}

struct FixtureTeamDTO: Decodable {
    let id: Int?
    let name: String?
    let name_full: String?
    let logo: String?
}

struct FixtureScoreDTO: Decodable {
    let home: Int?
    let away: Int?
}

extension FixturesDataDTO {
    func toDomain() -> WorldCupSchedule {
        WorldCupSchedule(
            leagueName: league?.name ?? "World Cup",
            leagueLogoUrl: league?.logo ?? "",
            timezoneNote: timezone_note ?? "",
            totalMatches: total_matches ?? 0,
            scheduleDays: (schedule ?? []).compactMap { $0.toDomain() }
        )
        .groupedByLocalTimezone()
    }
}

extension FixtureDayDTO {
    func toDomain() -> FixtureScheduleDay? {
        guard let date, !date.isEmpty else { return nil }
        
        return FixtureScheduleDay(
            id: date,
            date: date,
            dateLabel: date_label ?? date,
            weekdayLabel: weekday_label ?? "",
            matches: (matches ?? []).compactMap { $0.toDomain() }
        )
    }
}

extension FixtureMatchDTO {
    func toDomain() -> FootballFixture? {
        guard
            let fixtureId = fixture_id,
            let homeTeam = home_team?.toDomain(),
            let awayTeam = away_team?.toDomain()
        else {
            return nil
        }
        
        return FootballFixture(
            id: fixtureId,
            kickoffDate: parseKickoffDate(),
            kickoffTime: kickoff_time ?? "--:--",
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeScore: score?.home ?? 0,
            awayScore: score?.away ?? 0,
            statusShort: status_short ?? "NS",
            statusLabel: status ?? "",
            roundLabel: round_label ?? "",
            groupLabel: group_label ?? "",
            venue: venue ?? ""
        )
    }
    
    private func parseKickoffDate() -> Date? {
        if let kickoff_at, let date = Date.fromISO8601(kickoff_at) {
            return date
        }
        if let kickoff_timestamp {
            return Date(timeIntervalSince1970: TimeInterval(kickoff_timestamp))
        }
        return nil
    }
}

extension FixtureTeamDTO {
    func toDomain() -> FootballTeam? {
        guard let id, let name else { return nil }
        
        return FootballTeam(
            id: id,
            name: name,
            nameFull: name_full ?? name,
            logoUrl: logo ?? ""
        )
    }
}
