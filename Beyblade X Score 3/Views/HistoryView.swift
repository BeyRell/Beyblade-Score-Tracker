import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var matchHistory: MatchHistory
    
    private var recentMatches: [Match] {
        let matches = Array(matchHistory.matches.prefix(20))
        print("=== RECENT MATCHES ===")
        for match in matches {
            print("Match ID: \(match.id)")
            print("Player 1: \(match.player1Name)")
            print("Player 2: \(match.player2Name)")
            print("Games: \(match.games.count)")
            for game in match.games {
                print("  Game ID: \(game.id)")
                print("  Player 1 Beyblade: \(game.player1Beyblade.name)")
                print("  Player 2 Beyblade: \(game.player2Beyblade.name)")
                print("  Scoring History: \(game.scoringHistory.count) entries")
            }
        }
        print("=====================")
        return matches
    }
    
    var body: some View {
        NavigationView {
            List {
                if recentMatches.isEmpty {
                    Text("No matches played yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(recentMatches) { match in
                        NavigationLink(destination: MatchDetailView(match: match)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(match.player1Name.isEmpty ? "Player 1" : match.player1Name)
                                        .foregroundColor(.blue)
                                    Text("vs")
                                        .foregroundColor(.secondary)
                                    Text(match.player2Name.isEmpty ? "Player 2" : match.player2Name)
                                        .foregroundColor(.red)
                                }
                                .font(.headline)
                                
                                HStack {
                                    Text("\(match.games.count) game\(match.games.count == 1 ? "" : "s")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    if let winner = match.winner {
                                        Text("Winner: \(winner == 1 ? (match.player1Name.isEmpty ? "Player 1" : match.player1Name) : (match.player2Name.isEmpty ? "Player 2" : match.player2Name))")
                                            .font(.subheadline)
                                            .foregroundColor(winner == 1 ? .blue : .red)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Match History")
            .onAppear {
                print("HistoryView appeared")
                print("Total matches: \(matchHistory.matches.count)")
            }
        }
    }
}

struct MatchDetailView: View {
    let match: Match
    
    var body: some View {
        List {
            Section(header: Text("Match Info")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(match.player1Name.isEmpty ? "Player 1" : match.player1Name)
                            .foregroundColor(.blue)
                        Text("vs")
                            .foregroundColor(.secondary)
                        Text(match.player2Name.isEmpty ? "Player 2" : match.player2Name)
                            .foregroundColor(.red)
                    }
                    .font(.headline)
                    
                    if let winner = match.winner {
                        Text("Winner: \(winner == 1 ? (match.player1Name.isEmpty ? "Player 1" : match.player1Name) : (match.player2Name.isEmpty ? "Player 2" : match.player2Name))")
                            .font(.headline)
                            .foregroundColor(winner == 1 ? .blue : .red)
                    }
                    
                    Text("Target Score: \(match.targetScore)")
                        .font(.subheadline)
                }
            }
            
            ForEach(match.games) { game in
                Section(header: Text("Game \(match.games.firstIndex(of: game)! + 1)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Player 1 Info
                        PlayerInfoView(
                            name: game.player1Name.isEmpty ? "Player 1" : game.player1Name,
                            beyblade: game.player1Beyblade.name,
                            score: game.player1Score,
                            color: .blue
                        )
                        
                        Divider()
                        
                        // Player 2 Info
                        PlayerInfoView(
                            name: game.player2Name.isEmpty ? "Player 2" : game.player2Name,
                            beyblade: game.player2Beyblade.name,
                            score: game.player2Score,
                            color: .red
                        )
                        
                        Divider()
                        
                        // Scoring History
                        if !game.scoringHistory.isEmpty {
                            ScoringHistoryView(game: game)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Match Details")
    }
}

struct PlayerInfoView: View {
    let name: String
    let beyblade: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.subheadline)
                .foregroundColor(color)
            Text("Beyblade: \(beyblade)")
                .font(.subheadline)
                .foregroundColor(color)
            Text("Score: \(score)")
                .font(.title3)
                .foregroundColor(color)
        }
    }
}

struct ScoringHistoryView: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Scoring History")
                .font(.headline)
            ForEach(game.scoringHistory) { score in
                VStack(alignment: .leading) {
                    Text("Player \(score.player): \(score.type.rawValue) (\(score.type.points) points)")
                        .foregroundColor(score.player == 1 ? .blue : .red)
                    HStack {
                        Text("Beyblade: \(score.beyblade.name)")
                            .foregroundColor(score.player == 1 ? .blue : .red)
                        Text("vs")
                            .foregroundColor(.secondary)
                        Text(score.player == 1 ? game.player2Beyblade.name : game.player1Beyblade.name)
                            .foregroundColor(score.player == 1 ? .red : .blue)
                    }
                    .font(.subheadline)
                }
            }
        }
    }
} 