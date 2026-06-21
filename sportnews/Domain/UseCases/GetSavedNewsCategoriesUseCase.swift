//
//  GetSavedNewsCategoriesUseCase.swift
//  sportnews
//

import Foundation

protocol GetSavedNewsCategoriesUseCaseProtocol {
    func execute() -> [SportCategory]
}

final class GetSavedNewsCategoriesUseCase: GetSavedNewsCategoriesUseCaseProtocol {
    func execute() -> [SportCategory] {
        SavedNewsStorage.categories()
    }
}
