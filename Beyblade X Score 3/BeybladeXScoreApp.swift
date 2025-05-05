import SwiftUI

@main
struct BeybladeXScoreApp: App {
    @StateObject private var partsStore = PartsStore()
    @StateObject private var matchHistory = MatchHistory()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                PartsListView()
                    .tabItem {
                        Label("Parts", systemImage: "list.bullet")
                    }
                
                BeybladeBuilderView()
                    .tabItem {
                        Label("Builder", systemImage: "hammer")
                    }
                
                MatchView()
                    .tabItem {
                        Label("Match", systemImage: "gamecontroller")
                    }
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                
                StatisticsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
            }
            .environmentObject(partsStore)
            .environmentObject(matchHistory)
            .onAppear {
                print("=== BEYBLADE X SCORE APP INITIALIZATION ===")
                print("Loading sample parts...")
                partsStore.loadSampleParts()
                print("Total parts loaded: \(partsStore.parts.count)")
                print("Blades: \(partsStore.getParts(ofType: PartType.blade).count)")
                print("Ratchets: \(partsStore.getParts(ofType: PartType.ratchet).count)")
                print("Bits: \(partsStore.getParts(ofType: PartType.bit).count)")
                print("==========================================")
            }
        }
    }
} 