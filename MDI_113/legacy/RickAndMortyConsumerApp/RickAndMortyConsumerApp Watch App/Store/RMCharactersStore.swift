import Swift
import Foundation

@MainActor
final class RMCharactersStore: ObservableObject {
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingPage: Bool = false
    @Published var reachedEnd: Bool = false
    
    @Published var errorMessage: String?
    
    @Published var characters: [RMCharacter] = []

    private var page = 1
    
    func initialLoad() async {
        guard characters.isEmpty else { return }
        isInitialLoading = true
        
        defer { isInitialLoading = false }
        
        await loadNextPage()
    }
    
    func loadNextPage() async {
        guard !isLoadingPage, !reachedEnd else { return }
        
        isLoadingPage = true
        
        defer { isLoadingPage = false }
        
        do {
            let response = try await RMWebService.fetchRMCharacters(page: page)
            
            if response.results.isEmpty {
                reachedEnd = true
                return
            }
            
            characters.append(contentsOf: response.results)
            
            page += 1
            reachedEnd = (response.info.next == nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadMoreIfNeeded(idx: Int) async {
        guard !isLoadingPage, !reachedEnd else { return }
        
        let threshold = max(0, characters.count - 4)
        
        if idx >= threshold {
            await loadNextPage()
        }
    }
}
