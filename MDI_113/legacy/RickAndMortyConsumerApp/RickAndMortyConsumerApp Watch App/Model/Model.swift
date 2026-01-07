import Foundation

struct RMCharactersResponse: Decodable {
    let results: [RMCharacter]
    let info: RMInfoResponse
    
    struct RMInfoResponse: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
}

struct RMCharacter: Identifiable, Decodable {
    let id: Int
    let name: String
    let image: String
}
