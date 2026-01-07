import Foundation
import Swift

@MainActor
final class CharactersStore: ObservableObject {
    @Published var characters: [RMCharacter] = []
    @Published var isInitialLoading: Bool = false // only when store is created for first time
    @Published var isLoadingPage = false // we will use this one for the reast of the pages
    @Published var reachedEnd = false
    @Published var messageError: String?
    
    private var page = 0
    
    
    func initialLoad() async {
        guard characters.isEmpty else { return }
        isInitialLoading = true
        defer { isInitialLoading = false }
        
        await loadNextPage()
    }
    
    func refresh() async {
        page = 1
        reachedEnd = false
        characters.removeAll()
        messageError = nil
        await loadNextPage()
    }
    
    func loadMoreIfNeeded(current item: RMCharacter?) async {
        guard !isLoadingPage, !reachedEnd else { return }
        
        guard let currentItem = item else {
            await loadNextPage()
            return
        }
    }
    
    func loadNextPage() async {
        guard !isLoadingPage, !reachedEnd else { return }
        
        isLoadingPage = true
        
        defer { isLoadingPage = false }
        
        do {
            let response = try await RickAndMortyAPI.fetchCharacters(page: page)
            
            if response.results.isEmpty {
                reachedEnd = true
                return
            }
            characters.append(contentsOf: response.results)
            page += 1
            reachedEnd = (response.info.next == nil)
            messageError = nil
        } catch {
            messageError = error.localizedDescription
        }
    }
    
}
