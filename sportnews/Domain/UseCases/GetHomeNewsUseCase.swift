// Domain/UseCases/GetHomeNewsUseCase.swift
import Foundation

protocol GetHomeNewsUseCaseProtocol {
    func execute(page: Int, category: String?) async throws -> [SportNews]
}

final class GetHomeNewsUseCase: GetHomeNewsUseCaseProtocol {
    private let repository: HomeRepositoryProtocol
    
    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(page: Int = 0, category: String? = nil) async throws -> [SportNews] {
        // Có thể filter hoặc xử lý sắp xếp dữ liệu tại đây nếu cần
        return try await repository.getHomeNews(page: page, category: category)
    }
}
