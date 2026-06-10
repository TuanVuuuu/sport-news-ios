//
//  DiscoverRepository.swift
//  sportnews
//
//  Created by Nguyen Tuan Vu on 10/6/26.
//

import Foundation

struct DiscoverRepository: DiscoverRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDiscoverData() async throws -> [DiscoverSection] {
        let endpoint = NewsEndpoint.getDiscover
        
        let apiResponse: GetDiscoverResponseDTO = try await self.networkService.request(endpoint)
        
        let dtoList = apiResponse.body?.data ?? []
        
        return dtoList.map { $0.toEntity() }
    }
}
