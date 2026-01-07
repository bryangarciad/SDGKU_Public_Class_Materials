//
//  RickAndMortyConsumerAppApp.swift
//  RickAndMortyConsumerApp Watch App
//
//  Created by Ramses Duran on 02/12/25.
//

import SwiftUI

@main
struct RickAndMortyConsumerApp_Watch_AppApp: App {
    @StateObject private var store = RMCharactersStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CharactersGridView()
            }
            .environmentObject(store)
            .task {
                await store.initialLoad()
            }
        }
    }
}
