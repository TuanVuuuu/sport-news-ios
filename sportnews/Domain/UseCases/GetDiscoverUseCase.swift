//
//  GetDiscoverUseCase.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation

struct GetDiscoverUseCase {
    private let repository: DiscoverRepositoryProtocol
    
    init(repository: DiscoverRepositoryProtocol) {
        self.repository = repository
    }
    
    func excute() async throws -> [DiscoverSection] {
        return try await repository.fetchDiscoverData()
    }
}
