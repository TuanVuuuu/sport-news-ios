//
//  DiscoverCategoryViewAllView.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 14/6/26.
//

import SwiftUI

struct DiscoverCategoryViewAllView: View {
    let section: DiscoverSection
    @EnvironmentObject private var router: AppRouter
    
    @ObservedObject var viewModel: DiscoverViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(section.articles) { news in
                    NewsRowView(news: news)
                        .onTapGesture {
                            router.showNewsDetail(news)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color.white)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
