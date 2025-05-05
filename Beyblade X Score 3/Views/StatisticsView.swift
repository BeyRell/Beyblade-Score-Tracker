import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var matchHistory: MatchHistory
    @State private var selectedView: StatisticsType = .beyblade
    
    enum StatisticsType {
        case beyblade
        case part
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View Type", selection: $selectedView) {
                    Text("Beyblade vs Beyblade").tag(StatisticsType.beyblade)
                    Text("Part vs Part").tag(StatisticsType.part)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedView == .beyblade {
                    BeybladeStatisticsView()
                } else {
                    PartStatisticsView()
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct BeybladeStatisticsView: View {
    @EnvironmentObject var matchHistory: MatchHistory
    
    var body: some View {
        List {
            ForEach(getBeybladeMatchups(), id: \.self) { matchup in
                Section(header: Text("\(matchup.beyblade1) vs \(matchup.beyblade2)")) {
                    let stats = calculateBeybladeStats(beyblade1: matchup.beyblade1, beyblade2: matchup.beyblade2)
                    Text("Win Percentage: \(Int(stats.winPercentage * 100))%")
                    
                    ForEach(ScoringType.allCases, id: \.self) { type in
                        Text("\(type.rawValue): \(Int(stats.scoringTypePercentage(for: type) * 100))%")
                    }
                }
            }
        }
    }
    
    private func getBeybladeMatchups() -> [MatchResult] {
        var matchups: Set<MatchResult> = []
        
        for match in matchHistory.matches {
            for game in match.games {
                let beyblade1 = game.player1Beyblade.name
                let beyblade2 = game.player2Beyblade.name
                matchups.insert(MatchResult(beyblade1, beyblade2))
            }
        }
        
        return Array(matchups)
    }
    
    private func calculateBeybladeStats(beyblade1: String, beyblade2: String) -> MatchupStats {
        var wins = 0
        var losses = 0
        var scoringTypeCounts: [ScoringType: Int] = [:]
        var scoringTypeAgainst: [ScoringType: Int] = [:]
        
        for match in matchHistory.matches {
            for game in match.games {
                if game.player1Beyblade.name == beyblade1 && game.player2Beyblade.name == beyblade2 {
                    if game.winner == 1 {
                        wins += 1
                    } else {
                        losses += 1
                    }
                    
                    for score in game.scoringHistory {
                        if score.player == 1 {
                            scoringTypeCounts[score.type, default: 0] += 1
                        } else {
                            scoringTypeAgainst[score.type, default: 0] += 1
                        }
                    }
                }
            }
        }
        
        return MatchupStats(
            wins: wins,
            losses: losses,
            scoringTypeCounts: scoringTypeCounts,
            scoringTypeAgainst: scoringTypeAgainst
        )
    }
}

struct PartStatisticsView: View {
    @EnvironmentObject var matchHistory: MatchHistory
    
    var body: some View {
        List {
            ForEach(PartType.allCases, id: \.self) { type in
                Section(header: Text(type.rawValue.capitalized)) {
                    ForEach(getPartMatchups(ofType: type), id: \.self) { matchup in
                        VStack(alignment: .leading) {
                            Text("\(matchup.beyblade1) vs \(matchup.beyblade2)")
                            let stats = calculatePartStats(part1: matchup.beyblade1, part2: matchup.beyblade2, type: type)
                            Text("Win Percentage: \(Int(stats.winPercentage * 100))%")
                            
                            ForEach(ScoringType.allCases, id: \.self) { scoringType in
                                Text("\(scoringType.rawValue): \(Int(stats.scoringTypePercentage(for: scoringType) * 100))%")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getPartMatchups(ofType type: PartType) -> [MatchResult] {
        var matchups: Set<MatchResult> = []
        
        for match in matchHistory.matches {
            for game in match.games {
                let part1 = getPartFromBeyblade(game.player1Beyblade, type: type)
                let part2 = getPartFromBeyblade(game.player2Beyblade, type: type)
                matchups.insert(MatchResult(part1, part2))
            }
        }
        
        return Array(matchups)
    }
    
    private func getPartFromBeyblade(_ beyblade: Beyblade, type: PartType) -> String {
        switch type {
        case .blade:
            return beyblade.blade.name
        case .ratchet:
            return beyblade.ratchet.name
        case .bit:
            return beyblade.bit.name
        }
    }
    
    private func calculatePartStats(part1: String, part2: String, type: PartType) -> MatchupStats {
        var wins = 0
        var losses = 0
        var scoringTypeCounts: [ScoringType: Int] = [:]
        var scoringTypeAgainst: [ScoringType: Int] = [:]
        
        for match in matchHistory.matches {
            for game in match.games {
                let gamePart1 = getPartFromBeyblade(game.player1Beyblade, type: type)
                let gamePart2 = getPartFromBeyblade(game.player2Beyblade, type: type)
                
                if gamePart1 == part1 && gamePart2 == part2 {
                    if game.winner == 1 {
                        wins += 1
                    } else {
                        losses += 1
                    }
                    
                    for score in game.scoringHistory {
                        if score.player == 1 {
                            scoringTypeCounts[score.type, default: 0] += 1
                        } else {
                            scoringTypeAgainst[score.type, default: 0] += 1
                        }
                    }
                }
            }
        }
        
        return MatchupStats(
            wins: wins,
            losses: losses,
            scoringTypeCounts: scoringTypeCounts,
            scoringTypeAgainst: scoringTypeAgainst
        )
    }
} 