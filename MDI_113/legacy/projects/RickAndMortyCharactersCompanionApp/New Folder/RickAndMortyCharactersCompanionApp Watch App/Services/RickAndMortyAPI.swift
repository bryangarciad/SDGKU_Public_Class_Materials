import Foundation

enum APIError: Error, LocalizedError {
    case badUrl
    case decode
    case http(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .badUrl: return "Error While Creating The URL For The API"
            case .decode: return "Error While Decoding The JSON"
            case .unknown: return "Unknown Error"
            case .http(let code): return "HTTP Error Code \(code)"
        }
    }
}

struct RickAndMortyAPI {
    static var baseURL: String = "https://rickandmortyapi.com/api"
    
    static func fetchCharacters(page: Int) async throws -> CharactersResponse {
        guard let url = URL(string: "\(RickAndMortyAPI.baseURL)/character?page=\(page)")
        else { throw APIError.decode }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }
        guard (200...299).contains(http.statusCode) else { throw APIError.http(http.statusCode) }
        
        do {
            return try JSONDecoder().decode(CharactersResponse.self, from: data)
        } catch {
            throw APIError.decode
        }
    }
}
