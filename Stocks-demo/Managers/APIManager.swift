//
//  APIManager.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 28.10.2022.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    
    private struct Constants {
        static let apiKey = "cdgf0miad3ibuj2aim90cdgf0miad3ibuj2aim9g"
        static let baseUrl = "https://finnhub.io/api/v1/"
    }
    
    private init() {}
    
    // MARK: - Public
   
    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        request(url: url(
            for: .search,
            queryParams: ["q" : query]),
                expecting: SearchResponse.self,
                completion: completion)
    }
    
    // MARK: - Private
    private enum Endpoint: String {
        case search
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        // Добавление параметров в URL
        
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Добавление токена
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        // Конвертирование строки в суффикс строки
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        
        print("\n\(urlString)\n")
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            // недействительный Url
            completion(.failure(APIError.invalidUrl))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(APIError.noDataReturned))
            }
            do {
                 let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
