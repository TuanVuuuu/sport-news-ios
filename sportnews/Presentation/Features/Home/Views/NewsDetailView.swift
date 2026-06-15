//
//  NewsDetailView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 8/6/26.
//

import SwiftUI

struct NewsDetailView: View {
    let news: SportNews
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar chuẩn theo Mockup V2
            customNavigationBar
            
            // Nội dung WebView hiển thị bài viết chi tiết
            if !news.id.isEmpty {
                NewsWebView(urlString: news.id)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                VStack {
                    Spacer()
                    Text("Không tìm thấy bài viết")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }.background(Color.white)
    }
    
    // Header component tái hiện lại thiết kế của bạn
    private var customNavigationBar: some View {
        VStack(spacing: 4) {
            HStack {
                // 1. Nút Đóng (X)
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(width: 44, height: 44)
                
                // 2. Tiêu đề bài viết cắt gọn
                Text(news.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 3. Nút Share
                if let shareUrl = URL(string: news.id) {
                    ShareLink(item: shareUrl, subject: Text(news.title)) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }
                } else {
                    // Khởi tạo nút disable phòng trường hợp url lỗi
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, 8)
            
            Divider()
        }
        .background(Color.white)
    }

    private func close() {
        router.dismissFullScreen()
    }
}
