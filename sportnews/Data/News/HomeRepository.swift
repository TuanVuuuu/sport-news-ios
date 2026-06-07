import Foundation

final class HomeRepository: HomeRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getHomeNews(page: Int = 1, category: String? = nil) async throws -> [SportNews] {
        // 1. Định nghĩa Endpoint muốn gọi
        let endpoint = NewsEndpoint.getNews(category: category ?? "", page: page, limit: 20)
        
        // 2. Gọi Network Service và chỉ rõ kiểu dữ liệu DTO mong muốn nhận về là NewsApiResponseDTO
        let apiResponse: GetNewsListResponseDTO = try await networkService.request(endpoint)
        
        // 3. Map sang Domain Entity giống như trước
        let dtoList = apiResponse.body?.data ?? []
        return dtoList.enumerated().map { (index, dto) in
            dto.toDomain(isFeatured: index == 0)
        }
    }
    
    func getHomeCategories() async throws -> [SportCategory] {
        let endpoint = NewsEndpoint.getCategories(type: "home")
        let response: GetCategoriesResponseDTO = try await networkService.request(endpoint)
        return response.body?.data?.map { $0.toDomain() } ?? []
    }
}
