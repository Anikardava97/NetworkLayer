// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case other(Error)
}

public class NetworkManager {
    public static let shared = NetworkManager()
    
    public init() {}
    
    public func fetch<T: Decodable>(from urlString: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.other(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async{
                    completion(.success(decodedData))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
