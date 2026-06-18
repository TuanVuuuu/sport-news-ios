import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            appBar
            fixturesSection
            categorySelector
            homeNews
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .task {
            guard viewModel.newsList.isEmpty else { return }
            await viewModel.initializeHomeData()
        }
    }
    
    // MARK: - Subviews
    
    private var appBar: some View {
        HStack {
            Text("SportNews")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.8, green: 0.1, blue: 0.1))
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.id) { cat in
                    // Sử dụng Subview độc lập giúp tách biệt hoàn toàn Logic và Giao diện
                    CategoryTabButton(
                        category: cat,
                        isSelected: viewModel.selectedCategory == cat,
                        onTap: {
                            withAnimation(.spring()) {
                                _ = _Concurrency.Task {
                                    await viewModel.selectCategory(cat)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    @ViewBuilder
    private var fixturesSection: some View {
        if let schedule = viewModel.worldCupSchedule,
           let upcomingDay = viewModel.nearestUpcomingFixtureDay {
            WorldCupFixturesPreviewSection(
                schedule: schedule,
                day: upcomingDay,
                onSeeMore: {
                    router.showWorldCupFixtures(schedule)
                }
            )
//            .padding(.top, 12)
//            .background(Color(.systemGray6))
        }
    }
    
    @ViewBuilder
    private var homeNews: some View {
        if viewModel.isLoading && viewModel.newsList.isEmpty {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    if let featured = viewModel.featuredNews {
                        FeaturedCardView(news: featured).onTapGesture {
                            router.showNewsDetail(featured)
                        }
                    }
                    
                    // 2. List tin tức phía dưới
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredNews) { news in
                            NewsRowView(news: news)
                                .onAppear {
                                    let filteredList = viewModel.filteredNews
                                    let totalItems = filteredList.count
                                    
                                    // Kích hoạt sớm khi người dùng cuộn tới phần tử thứ (Tổng - 4)
                                    if totalItems >= 4 {
                                        let triggerIndex = totalItems - 4
                                        if news.id == filteredList[triggerIndex].id {
                                            _Concurrency.Task {
                                                await viewModel.loadMoreNews()
                                            }
                                        }
                                    } else if news.id == filteredList.last?.id {
                                        // Phòng trường hợp danh sách quá ngắn (ít hơn 3 phần tử), vẫn cho phép ăn theo item cuối
                                        _Concurrency.Task {
                                            await viewModel.loadMoreNews()
                                        }
                                    }
                                }
                                .onTapGesture {
                                    router.showNewsDetail(news)
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 3. Vòng xoay Loading khi kéo cuối trang (Load more)
                    if viewModel.isLoadMoreLoading {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .padding(.vertical, 12)
            }
            .refreshable {
                await viewModel.initializeHomeData()
            }
        }
    }
}

// MARK: - Component: Category Tab Button (Nút chọn danh mục độc lập)
struct CategoryTabButton: View {
    let category: SportCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(category.name)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(isSelected ? Color(red: 0.8, green: 0.1, blue: 0.1) : Color.white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
            .onTapGesture {
                onTap()
            }
    }
}

// MARK: - Component: Featured Card (Banner tin nổi bật)
struct FeaturedCardView: View {
    let news: SportNews
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: news.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.black.opacity(0.1)
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Gradient phủ mờ giúp đọc chữ dễ hơn
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(news.category.uppercased()) • \(news.timeAgo)")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.8, green: 0.1, blue: 0.1))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Text(news.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
            }
            .padding()
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Component: News Row (Từng dòng tin)
struct NewsRowView: View {
    let news: SportNews
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Nội dung text nằm bên trái chuẩn chỉ
            VStack(alignment: .leading, spacing: 8) {
                Text("\(news.source.uppercased()) • \(news.timeAgo)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(news.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 8) // Giữ khoảng cách an toàn tối thiểu với ảnh
            
            // Hình ảnh thumbnail đưa sang bên phải
            AsyncImage(url: URL(string: news.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 100, height: 80)
            .cornerRadius(8)
            .clipped()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
