//
//  DiscoverViewModel.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation
import Combine

@MainActor
class DiscoverViewModel: ObservableObject {
    private let getDiscoverUseCase: GetDiscoverUseCase
    
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sections: [DiscoverSection] = []
    
    @Published var quickTags: [String] = ["v-league", "🏆 world cup 2026", "roland garros", "chuyển nhượng", "euro 2024"]
    
    init(getDiscoverUseCase: GetDiscoverUseCase) {
        self.getDiscoverUseCase = getDiscoverUseCase
    }
    
    func loadDiscoverData() async {
        self.isLoading = true
        
        do {
            self.sections = try await getDiscoverUseCase.excute()
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
}
