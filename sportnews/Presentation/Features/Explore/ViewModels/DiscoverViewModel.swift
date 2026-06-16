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
    private let getKeywordSuggestionsUseCase: GetKeywordSuggestionsUseCase
    
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sections: [DiscoverSection] = []
    @Published var keywordSuggestions: [KeywordSuggestions] = []


    
    init(
        getDiscoverUseCase: GetDiscoverUseCase,
        getKeywordSuggestionsUseCase: GetKeywordSuggestionsUseCase
    ) {
        self.getDiscoverUseCase = getDiscoverUseCase
        self.getKeywordSuggestionsUseCase = getKeywordSuggestionsUseCase
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
    
    
    func loadKeywordsSuggestions() async {
        do {
            self.keywordSuggestions = try await getKeywordSuggestionsUseCase.excute()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func searchDiscoverByKeyword(text: String) async {
        self.isLoading = true
        do {
            let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                await loadDiscoverData()  // rỗng → quay lại discover mặc định
                return
            }
            
            self.sections = try await getKeywordSuggestionsUseCase.search(text: text)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    func selectedSearchText(text: String) {
        searchText = text
    }
}
