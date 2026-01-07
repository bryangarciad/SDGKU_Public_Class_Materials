import Foundation


enum RMApiError: Error, LocalizedError {
    case badURL
    case httpError(Int)
    case decodeError
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .badURL: return "Bad URL"
            case .httpError(let code): return "HTTP Error: \(code)"
            case .decodeError: return "Decoding Error"
            case .unknown: return "Something Went Wrong"
        }
    }
}

struct RMWebService {
    static var hostName: String = "https://rickandmortyapi.com/api" // -> URL
    
    static func fetchRMCharacters(page: Int) async throws -> RMCharactersResponse {
        let charactersEndpoint = "character"
        
        guard let url = URL(string: "\(RMWebService.hostName)/\(charactersEndpoint)?page=\(page)") else {
            throw RMApiError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw RMApiError.unknown
        }
   
        guard(200...299).contains(http.statusCode) else {
            throw RMApiError.httpError(http.statusCode)
        }

        do {
            // we want to get from response string to an array of RMCharacters
            return try JSONDecoder().decode(RMCharactersResponse.self, from: data)
        } catch {
            throw RMApiError.decodeError
        }
    }
}
