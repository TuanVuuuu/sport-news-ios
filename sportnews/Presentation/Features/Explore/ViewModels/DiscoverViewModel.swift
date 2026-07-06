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
    
    private let selectKeywordPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(
        getDiscoverUseCase: GetDiscoverUseCase,
        getKeywordSuggestionsUseCase: GetKeywordSuggestionsUseCase
    ) {
        self.getDiscoverUseCase = getDiscoverUseCase
        self.getKeywordSuggestionsUseCase = getKeywordSuggestionsUseCase
        
        setupPipeline()
    }
    
    private func setupPipeline() {
        selectKeywordPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .map { [weak self] query -> AnyPublisher<[DiscoverSection], Never> in
                guard let self = self else {return Just([]).eraseToAnyPublisher()}
                
                return Future {
                    promise in
                    
                    Task {
                        do {
                            let result = try await self.getKeywordSuggestionsUseCase.search(text: query)
                            promise(.success(result))
                        } catch {
                            promise(.success([]))
                        }
                    }
                }.eraseToAnyPublisher()
                
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSections in
                self?.sections = newSections
                self?.isLoading = false
            }
            .store(in: &cancellables)
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
    
    func searchDiscoverByKeyword(text: String) {
        
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            Task {
                await loadDiscoverData()
            }
            // rỗng → quay lại discover mặc định
            return
        }
        
        selectKeywordPublisher.send(query)
    }
    
    func selectedSearchText(text: String) {
        searchText = text
    }
}
