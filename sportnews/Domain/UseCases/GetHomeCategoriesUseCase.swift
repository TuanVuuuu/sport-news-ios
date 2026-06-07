//
//  GetHomeCategoriesUseCase.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 7/6/26.
//

import Foundation

protocol GetHomeCategoriesUseCaseProtocol {
    func execute() async throws -> [SportCategory]
}

final class GetHomeCategoriesUseCase: GetHomeCategoriesUseCaseProtocol {
    private let repository: HomeRepositoryProtocol
    
    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [SportCategory] {
        return try await repository.getHomeCategories()
    }
}
