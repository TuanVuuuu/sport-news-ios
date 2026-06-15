// Domain/Entities/SportNews.swift
import Foundation

struct SportNews: Hashable, Identifiable {
    let id: String
    let title: String
    let source: String        // Nguồn tin (VnExpress, Soha...)
    let timeAgo: String       // Thời gian hiển thị
    let category: String      // Danh mục để lọc tab
    let imageUrl: String      // Link ảnh thumbnail
    let isFeatured: Bool      // Đánh dấu tin nổi bật
}
