import Foundation

extension WorldCupSchedule {
    /// Nhóm lại lịch thi đấu theo ngày local của thiết bị.
    func groupedByLocalTimezone(calendar: Calendar = .current) -> WorldCupSchedule {
        var seenMatchIDs = Set<Int>()
        let allMatches = scheduleDays
            .flatMap(\.matches)
            .filter { seenMatchIDs.insert($0.id).inserted }

        guard !allMatches.isEmpty else { return self }

        var matchesByDay: [Date: [FootballFixture]] = [:]
        var matchesWithoutKickoff: [FootballFixture] = []

        for match in allMatches {
            guard let kickoffDate = match.kickoffDate else {
                matchesWithoutKickoff.append(match)
                continue
            }
            let dayStart = calendar.startOfDay(for: kickoffDate)
            matchesByDay[dayStart, default: []].append(match)
        }

        var regroupedDays = matchesByDay.keys.sorted().map { dayStart in
            let matches = (matchesByDay[dayStart] ?? []).sorted {
                ($0.kickoffDate ?? .distantFuture) < ($1.kickoffDate ?? .distantFuture)
            }
            return FixtureScheduleDay(
                id: Self.localDayID(for: dayStart, calendar: calendar),
                date: Self.localDayID(for: dayStart, calendar: calendar),
                dateLabel: Self.localDateLabel(for: dayStart, calendar: calendar),
                weekdayLabel: Self.localWeekdayLabel(for: dayStart, calendar: calendar),
                matches: matches
            )
        }

        if !matchesWithoutKickoff.isEmpty {
            for day in scheduleDays {
                let orphanMatches = day.matches.filter { match in
                    match.kickoffDate == nil && matchesWithoutKickoff.contains { $0.id == match.id }
                }
                guard !orphanMatches.isEmpty else { continue }

                regroupedDays.append(
                    FixtureScheduleDay(
                        id: day.date,
                        date: day.date,
                        dateLabel: day.dateLabel,
                        weekdayLabel: day.weekdayLabel,
                        matches: orphanMatches
                    )
                )
            }
            regroupedDays.sort { $0.id < $1.id }
        }

        return WorldCupSchedule(
            leagueName: leagueName,
            leagueLogoUrl: leagueLogoUrl,
            timezoneNote: localizedTimezoneNote(calendar: calendar),
            totalMatches: totalMatches,
            scheduleDays: regroupedDays
        )
    }

    private func localizedTimezoneNote(calendar: Calendar) -> String {
        let tzName = calendar.timeZone.identifier
        if timezoneNote.isEmpty {
            return "Giờ hiển thị theo \(tzName)"
        }
        return "\(timezoneNote) • Giờ hiển thị theo \(tzName)"
    }

    private static func localDayID(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func localDateLabel(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }

    private static func localWeekdayLabel(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE"
        let label = formatter.string(from: date)
        return label.prefix(1).uppercased() + label.dropFirst()
    }
}
