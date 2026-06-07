import Foundation

protocol HomeRepositoryProtocol {
    /// Hàm định nghĩa việc lấy danh sách tin tức cho màn hình trang chủ
    func getHomeNews(page: Int, category: String?) async throws -> [SportNews]
    
    /// Hàm định nghĩa lấy danh sách danh mục
    func getHomeCategories() async throws -> [SportCategory]
}
