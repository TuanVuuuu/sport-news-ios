import SwiftUI

struct WorldCupFixturesDetailView: View {
    let schedule: WorldCupSchedule
    @State private var selectedDayIndex: Int
    
    init(schedule: WorldCupSchedule) {
        self.schedule = schedule
        _selectedDayIndex = State(initialValue: schedule.defaultSelectedDayIndex())
    }
    
    var body: some View {
        ScrollView {
            WorldCupFixturesSection(
                schedule: schedule,
                selectedDayIndex: selectedDayIndex,
                onSelectDay: { selectedDayIndex = $0 }
            )
            .padding(.top, 12)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Lịch thi đấu")
        .navigationBarTitleDisplayMode(.inline)
    }
}
