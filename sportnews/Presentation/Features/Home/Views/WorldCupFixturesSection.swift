import SwiftUI

struct WorldCupFixturesPreviewSection: View {
    let schedule: WorldCupSchedule
    let day: FixtureScheduleDay
    let onSeeMore: () -> Void
    
    private var upcomingMatches: [FootballFixture] {
        day.matches.filter { $0.isUpcoming && $0.isKickoffInFuture }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                AsyncImage(url: URL(string: schedule.leagueLogoUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.15)
                }
                .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Lịch thi đấu \(schedule.leagueName)")
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                        
                        Spacer(minLength: 8)
                        
                        Button(action: onSeeMore) {
                            HStack(spacing: 4) {
                                Text("Xem thêm")
                                    .font(.system(size: 13, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(AppColors.accentRed)
                        }
                    }
                    
                    Text("\(day.weekdayLabel) • \(day.dateLabel)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(upcomingMatches) { match in
                        FixtureMatchPreviewCard(
                            match: match,
                            width: UIScreen.main.bounds.width * 0.6
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 76)
        }
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
//        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.06), radius: 3, x: 0, y: 1)
//        .padding(.horizontal)
    }
}

private struct FixtureMatchPreviewCard: View {
    let match: FootballFixture
    let width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(match.groupLabel)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.accentRed)
            
            HStack(alignment: .center, spacing: 10) {
                teamSide(team: match.homeTeam, isHome: true)
                
                Text(match.localizedKickoffTime)
                    .font(.system(size: 17, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(AppColors.accentRed)
                    .frame(minWidth: 48)
                
                teamSide(team: match.awayTeam, isHome: false)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: width, alignment: .leading)
        .background(AppColors.surfaceMuted)
        .cornerRadius(12)
    }
    
    private func teamSide(team: FootballTeam, isHome: Bool) -> some View {
        HStack(spacing: 6) {
            if isHome {
                teamLogo(url: team.logoUrl)
                Text(team.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            } else {
                Text(team.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
                teamLogo(url: team.logoUrl)
            }
        }
        .frame(maxWidth: .infinity, alignment: isHome ? .leading : .trailing)
    }
    
    private func teamLogo(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            Color.gray.opacity(0.15)
        }
        .frame(width: 28, height: 28)
    }
}

struct WorldCupFixturesSection: View {
    let schedule: WorldCupSchedule
    let selectedDayIndex: Int
    let onSelectDay: (Int) -> Void
    
    private var selectedDay: FixtureScheduleDay? {
        guard schedule.scheduleDays.indices.contains(selectedDayIndex) else { return nil }
        return schedule.scheduleDays[selectedDayIndex]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            dateSelector
            matchesList
        }
        .padding(.vertical, 12)
//        .background(Color.white)
//        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.06), radius: 3, x: 0, y: 1)
//        .padding(.horizontal)
    }
    
    private var header: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: schedule.leagueLogoUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Lịch thi đấu \(schedule.leagueName)")
                    .font(.system(size: 16, weight: .bold))
                
                if !schedule.timezoneNote.isEmpty {
                    Text(schedule.timezoneNote)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("\(schedule.totalMatches) trận")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppColors.backgroundCard)
        
    }
    
    private var dateSelector: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(schedule.scheduleDays.enumerated()), id: \.element.id) { index, day in
                        FixtureDateTab(
                            day: day,
                            isSelected: index == selectedDayIndex,
                            onTap: { onSelectDay(index) }
                        )
                        .id(day.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .onChange(of: selectedDayIndex) { newIndex in
                guard schedule.scheduleDays.indices.contains(newIndex) else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(schedule.scheduleDays[newIndex].id, anchor: .center)
                }
            }
            .onAppear {
                guard schedule.scheduleDays.indices.contains(selectedDayIndex) else { return }
                proxy.scrollTo(schedule.scheduleDays[selectedDayIndex].id, anchor: .center)
            }
        }
    }
    
    @ViewBuilder
    private var matchesList: some View {
        if let selectedDay {
            VStack(spacing: 10) {
                ForEach(selectedDay.matches) { match in
                    FixtureMatchRow(match: match)
                }
            }
            .padding(.horizontal, 16)
        } else {
            Text("Chưa có lịch thi đấu")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }
}

private struct FixtureDateTab: View {
    let day: FixtureScheduleDay
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Text(day.weekdayLabel)
                .font(.system(size: 10, weight: .medium))
            Text(day.dateLabel)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? AppColors.accentRed : AppColors.backgroundCard)
        .foregroundColor(isSelected ? AppColors.textOnAccent : .primary)
        .cornerRadius(10)
        .onTapGesture(perform: onTap)
    }
}

struct FixtureMatchRow: View {
    let match: FootballFixture
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            matchRow
            
            if !match.venue.isEmpty {
                Text(match.venue)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppColors.surfaceMuted)
        .cornerRadius(12)
    }
    
    private var headerRow: some View {
        HStack(spacing: 6) {
            Text(match.groupLabel)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppColors.accentRed)
            
            Text(match.roundLabel)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer(minLength: 8)
            
            statusBadge
        }
    }
    
    private var matchRow: some View {
        HStack(spacing: 8) {
            homeTeamSide
            centerContent
                .frame(minWidth: 52)
            awayTeamSide
        }
    }
    
    private var homeTeamSide: some View {
        HStack(spacing: 6) {
            teamLogo(url: match.homeTeam.logoUrl)
            Text(match.homeTeam.name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var awayTeamSide: some View {
        HStack(spacing: 6) {
            Text(match.awayTeam.name)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
            teamLogo(url: match.awayTeam.logoUrl)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    private var centerContent: some View {
        if let scoreText = match.scoreText {
            Text(scoreText)
                .font(.system(size: 17, weight: .bold))
                .monospacedDigit()
        } else {
            Text(match.localizedKickoffTime)
                .font(.system(size: 17, weight: .bold))
                .monospacedDigit()
        }
    }
    
    private var statusBadge: some View {
        let style = statusBadgeStyle
        
        return Text(style.text)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.background)
            .foregroundColor(style.foreground)
            .clipShape(Capsule())
    }
    
    private var statusBadgeStyle: (text: String, background: Color, foreground: Color) {
        switch match.statusShort {
        case "FT":
            return ("Kết thúc", Color.white.opacity(0.12), Color.secondary)
        case "NS":
            return (match.localizedKickoffTime, AppColors.accentRedSoft, AppColors.accentRed)
        case "LIVE", "1H", "2H", "HT":
            return ("Trực tiếp", Color.green.opacity(0.18), .green)
        default:
            return (match.statusShort, Color.white.opacity(0.12), .secondary)
        }
    }
    
    private func teamLogo(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            Color.gray.opacity(0.15)
        }
        .frame(width: 22, height: 22)
        .cornerRadius(2)
    }
}
