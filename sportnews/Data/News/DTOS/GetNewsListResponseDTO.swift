// Data/News/DTOs/GetNewsListResponseDTO.swift
import Foundation

// 1. Cấu trúc gốc phản hồi từ API danh sách tin tức
struct GetNewsListResponseDTO: Decodable {
    let status: Int
    let message: String?
    let body: NewsListBodyDTO?
}

// 2. Đối tượng chứa dữ liệu chính và thông tin phân trang
struct NewsListBodyDTO: Decodable {
    let data: [NewsArticleDTO]?
    let pagination: PaginationDTO?
}

// 3. Thông tin phân trang (Dành cho việc mở rộng Load More sau này)
struct PaginationDTO: Decodable {
    let current_page: Int?
    let total_pages: Int?
    let total_items: Int?
    let has_next: Bool?
}

// 4. Chi tiết từng item bài viết nhận về từ API
struct NewsArticleDTO: Decodable {
    let id: String
    let category_id: String?
    let category_name: String?
    let source: String?
    let title: String?
    let description: String?
    let thumbnail_url: String?
    let link: String?
    let published_at: String?
    let createAt: String?
    
    /// Hàm mapper: Chuyển đổi dữ liệu thô (DTO) của tầng Data
    /// thành Model sạch (SportNews) của tầng Domain.
    func toDomain(isFeatured: Bool = false) -> SportNews {
        return SportNews(
            id: self.id,
            title: self.title ?? "",
            source: self.source ?? "Tin tức",
            timeAgo: parsePublishedDate(self.published_at ?? ""),
            category: self.category_name ?? "Thể thao",
            imageUrl: self.thumbnail_url ?? "",
            isFeatured: isFeatured
        )
    }
    
    /// Logic xử lý hiển thị thời gian thô từ API (Ví dụ: "Sat, 06 Jun 2026 19:11:43 +0700")
    private func parsePublishedDate(_ dateString: String) -> String {
        // Cách xử lý nhanh bằng cắt chuỗi để lấy giờ: "19:11:43"
        let components = dateString.components(separatedBy: " ")
        if components.count > 4 {
            return "\(components[4])"
        }
        return "Vừa xong"
    }
}
