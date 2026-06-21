//
//  ToggleSavedNewsUseCase.swift
//  sportnews
//

import Foundation

protocol ToggleSavedNewsUseCaseProtocol {
    func execute(id: String, categoryId: String, categoryName: String) -> Bool
    func isSaved(id: String) -> Bool
    func savedIds() -> Set<String>
}

final class ToggleSavedNewsUseCase: ToggleSavedNewsUseCaseProtocol {
    func execute(id: String, categoryId: String, categoryName: String) -> Bool {
        SavedNewsStorage.toggle(id: id, categoryId: categoryId, categoryName: categoryName)
    }

    func isSaved(id: String) -> Bool {
        SavedNewsStorage.isSaved(id: id)
    }

    func savedIds() -> Set<String> {
        SavedNewsStorage.savedIds()
    }
}
