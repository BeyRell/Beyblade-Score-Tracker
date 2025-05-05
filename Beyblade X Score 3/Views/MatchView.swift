import SwiftUI

struct MatchView: View {
    @EnvironmentObject var partsStore: PartsStore
    @EnvironmentObject var matchHistory: MatchHistory
    
    @State private var player1Name: String = ""
    @State private var player2Name: String = ""
    @State private var targetScore: Int = 4
    @State private var player1Beyblades: [Beyblade] = []
    @State private var player2Beyblades: [Beyblade] = []
    @State private var currentGame: Game?
    @State private var currentMatch: Match?
    @State private var showingGameSummary = false
    @State private var showingMatchSummary = false
    
    var body: some View {
        NavigationView {
            if currentMatch == nil {
                matchSetupView
            } else if currentGame == nil {
                gameSetupView
            } else {
                gameView
            }
        }
    }
    
    private var matchSetupView: some View {
        Form {
            Section {
                Button("Simple Scoreboard") {
                    startSimpleMatch()
                }
            }
            
            Section(header: Text("Player 1")) {
                TextField("Player 1 Name", text: $player1Name)
                NavigationLink("Select Beyblades", destination: BeybladeSelectionView(selectedBeyblades: $player1Beyblades))
            }
            
            Section(header: Text("Player 2")) {
                TextField("Player 2 Name", text: $player2Name)
                NavigationLink("Select Beyblades", destination: BeybladeSelectionView(selectedBeyblades: $player2Beyblades))
            }
            
            Section(header: Text("Match Settings")) {
                VStack(alignment: .leading) {
                    Text("Target Score: \(targetScore)")
                        .font(.headline)
                    
                    HStack {
                        Text("4")
                        Slider(value: Binding(
                            get: { Double(targetScore) },
                            set: { targetScore = Int($0) }
                        ), in: 4...7, step: 1)
                        Text("7")
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Start Match") {
                    startMatch()
                }
                .disabled(player1Beyblades.isEmpty || player2Beyblades.isEmpty)
            }
        }
        .navigationTitle("Match Setup")
    }
    
    private var gameSetupView: some View {
        Form {
            Section(header: Text("Player 1")) {
                PlayerBeybladePicker(
                    selectedBeyblade: Binding(
                        get: { currentGame?.player1Beyblade },
                        set: { newValue in
                            if let newValue = newValue {
                                currentGame = Game(
                                    player1Beyblade: newValue,
                                    player2Beyblade: currentGame?.player2Beyblade ?? player2Beyblades.first!,
                                    player1Name: player1Name,
                                    player2Name: player2Name,
                                    targetScore: targetScore
                                )
                            }
                        }
                    ),
                    playerName: player1Name,
                    availableBeyblades: player1Beyblades
                )
            }
            
            Section(header: Text("Player 2")) {
                PlayerBeybladePicker(
                    selectedBeyblade: Binding(
                        get: { currentGame?.player2Beyblade },
                        set: { newValue in
                            if let newValue = newValue {
                                currentGame = Game(
                                    player1Beyblade: currentGame?.player1Beyblade ?? player1Beyblades.first!,
                                    player2Beyblade: newValue,
                                    player1Name: player1Name,
                                    player2Name: player2Name,
                                    targetScore: targetScore
                                )
                            }
                        }
                    ),
                    playerName: player2Name,
                    availableBeyblades: player2Beyblades
                )
            }
            
            Section {
                Button("Start Game") {
                    if let game = currentGame {
                        startGame(game)
                    }
                }
                .disabled(currentGame?.player1Beyblade == nil || currentGame?.player2Beyblade == nil)
            }
        }
        .navigationTitle("Game Setup")
    }
    
    private var gameView: some View {
        VStack {
            if let game = currentGame, let match = currentMatch {
                // Player 1 Scoring Section
                VStack {
                    Text(player1Name.isEmpty ? "Player 1" : player1Name)
                        .font(.headline)
                    
                    PlayerBeybladePicker(
                        selectedBeyblade: Binding(
                            get: { game.player1Beyblade },
                            set: { newValue in
                                if let newValue = newValue {
                                    var updatedGame = game
                                    updatedGame.player1Beyblade = newValue
                                    currentGame = updatedGame
                                }
                            }
                        ),
                        playerName: player1Name,
                        availableBeyblades: player1Beyblades
                    )
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(ScoringType.allCases, id: \.self) { type in
                            Button(action: {
                                scorePoint(type: type, player: 1)
                            }) {
                                VStack(spacing: 4) {
                                    Text(type.rawValue)
                                        .font(.caption)
                                    Text("\(type.points)")
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Center Score Display
                VStack(spacing: 12) {
                    Text("First to \(targetScore) points wins")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Text("\(game.player1Score)")
                            .font(.system(size: 48, weight: .bold))
                        Text("Wins: \(match.games.filter { $0.winner == 1 }.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("vs")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Text("\(game.player2Score)")
                            .font(.system(size: 48, weight: .bold))
                        Text("Wins: \(match.games.filter { $0.winner == 2 }.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                // Player 2 Scoring Section
                VStack {
                    Text(player2Name.isEmpty ? "Player 2" : player2Name)
                        .font(.headline)
                    
                    PlayerBeybladePicker(
                        selectedBeyblade: Binding(
                            get: { game.player2Beyblade },
                            set: { newValue in
                                if let newValue = newValue {
                                    var updatedGame = game
                                    updatedGame.player2Beyblade = newValue
                                    currentGame = updatedGame
                                }
                            }
                        ),
                        playerName: player2Name,
                        availableBeyblades: player2Beyblades
                    )
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(ScoringType.allCases, id: \.self) { type in
                            Button(action: {
                                scorePoint(type: type, player: 2)
                            }) {
                                VStack(spacing: 4) {
                                    Text(type.rawValue)
                                        .font(.caption)
                                    Text("\(type.points)")
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingGameSummary) {
            if let game = currentGame {
                GameSummaryView(game: game) {
                    showingGameSummary = false
                    checkMatchCompletion()
                }
            }
        }
        .sheet(isPresented: $showingMatchSummary) {
            if let match = currentMatch {
                MatchSummaryView(match: match) {
                    resetMatch()
                }
            }
        }
    }
    
    private func startMatch() {
        currentMatch = Match(
            player1Name: player1Name,
            player2Name: player2Name,
            player1Beyblades: player1Beyblades,
            player2Beyblades: player2Beyblades,
            targetScore: targetScore
        )
        
        // Initialize the first game
        if let firstBeyblade1 = player1Beyblades.first,
           let firstBeyblade2 = player2Beyblades.first {
            currentGame = Game(
                player1Beyblade: firstBeyblade1,
                player2Beyblade: firstBeyblade2,
                player1Name: player1Name,
                player2Name: player2Name,
                targetScore: targetScore
            )
        }
    }
    
    private func startGame(_ game: Game) {
        // Set the current game
        currentGame = game
    }
    
    private func scorePoint(type: ScoringType, player: Int) {
        guard var game = currentGame else { return }
        
        if player == 1 {
            game.player1Score += type.points
        } else {
            game.player2Score += type.points
        }
        
        // Record which Beyblade was used for this score
        let beybladeUsed = player == 1 ? game.player1Beyblade : game.player2Beyblade
        game.scoringHistory.append(ScoringHistoryEntry(
            player: player,
            type: type,
            beyblade: beybladeUsed
        ))
        
        if game.player1Score >= game.targetScore || game.player2Score >= game.targetScore {
            game.winner = game.player1Score > game.player2Score ? 1 : 2
            
            // Update the match's games array with the completed game
            if var match = currentMatch {
                match.games.append(game)
                currentMatch = match
                
                // Check if the match is complete
                let player1Wins = match.games.filter { $0.winner == 1 }.count
                let player2Wins = match.games.filter { $0.winner == 2 }.count
                
                if player1Wins >= 2 || player2Wins >= 2 {
                    // Match is over, show summary
                    var updatedMatch = match
                    updatedMatch.winner = player1Wins >= 2 ? 1 : 2
                    currentMatch = updatedMatch
                    
                    // Only add to history if it's not a simple match
                    if !updatedMatch.isSimpleMatch {
                        matchHistory.addMatch(updatedMatch)
                    }
                    
                    showingMatchSummary = true
                } else {
                    // Continue to next game
                    if let firstBeyblade1 = player1Beyblades.first,
                       let firstBeyblade2 = player2Beyblades.first {
                        // Use selected Beyblades if available
                        currentGame = Game(
                            player1Beyblade: firstBeyblade1,
                            player2Beyblade: firstBeyblade2,
                            player1Name: player1Name,
                            player2Name: player2Name,
                            targetScore: targetScore
                        )
                    } else {
                        // Use default Beyblades for simple mode
                        currentGame = Game(
                            player1Beyblade: Beyblade(blade: partsStore.getParts(ofType: .blade).first!,
                                                    ratchet: partsStore.getParts(ofType: .ratchet).first!,
                                                    bit: partsStore.getParts(ofType: .bit).first!),
                            player2Beyblade: Beyblade(blade: partsStore.getParts(ofType: .blade).first!,
                                                    ratchet: partsStore.getParts(ofType: .ratchet).first!,
                                                    bit: partsStore.getParts(ofType: .bit).first!),
                            player1Name: player1Name,
                            player2Name: player2Name,
                            targetScore: targetScore
                        )
                    }
                }
            }
            
            showingGameSummary = true
        }
        
        currentGame = game
    }
    
    private func resetMatch() {
        currentMatch = nil
        currentGame = nil
        player1Name = ""
        player2Name = ""
        player1Beyblades = []
        player2Beyblades = []
        showingGameSummary = false
        showingMatchSummary = false
    }
    
    private func checkMatchCompletion() {
        guard let match = currentMatch else { return }
        
        let player1Wins = match.games.filter { $0.winner == 1 }.count
        let player2Wins = match.games.filter { $0.winner == 2 }.count
        
        print("Player 1 wins: \(player1Wins)")
        print("Player 2 wins: \(player2Wins)")
        
        if player1Wins >= 2 || player2Wins >= 2 {
            // Match is over, show summary
            var updatedMatch = match
            updatedMatch.winner = player1Wins >= 2 ? 1 : 2
            currentMatch = updatedMatch
            
            // Add the completed match to history
            matchHistory.addMatch(updatedMatch)
            
            showingMatchSummary = true
        } else {
            // Continue to next game
            if let firstBeyblade1 = player1Beyblades.first,
               let firstBeyblade2 = player2Beyblades.first {
                // Use selected Beyblades if available
                currentGame = Game(
                    player1Beyblade: firstBeyblade1,
                    player2Beyblade: firstBeyblade2,
                    player1Name: player1Name,
                    player2Name: player2Name,
                    targetScore: targetScore
                )
            } else {
                // Use default Beyblades for simple mode
                currentGame = Game(
                    player1Beyblade: Beyblade(blade: partsStore.getParts(ofType: .blade).first!,
                                            ratchet: partsStore.getParts(ofType: .ratchet).first!,
                                            bit: partsStore.getParts(ofType: .bit).first!),
                    player2Beyblade: Beyblade(blade: partsStore.getParts(ofType: .blade).first!,
                                            ratchet: partsStore.getParts(ofType: .ratchet).first!,
                                            bit: partsStore.getParts(ofType: .bit).first!),
                    player1Name: player1Name,
                    player2Name: player2Name,
                    targetScore: targetScore
                )
            }
        }
    }
    
    private func startSimpleMatch() {
        // Reset any existing state
        resetMatch()
        
        // Create a simple match with default values
        currentMatch = Match(
            player1Name: "Player 1",
            player2Name: "Player 2",
            player1Beyblades: [],
            player2Beyblades: [],
            targetScore: targetScore,
            isSimpleMatch: true  // Mark this as a simple match
        )
        
        // Create a simple game with default values
        currentGame = Game(
            player1Beyblade: Beyblade(
                blade: Part(name: "Default", type: .blade),
                ratchet: Part(name: "Default", type: .ratchet),
                bit: Part(name: "Default", type: .bit)
            ),
            player2Beyblade: Beyblade(
                blade: Part(name: "Default", type: .blade),
                ratchet: Part(name: "Default", type: .ratchet),
                bit: Part(name: "Default", type: .bit)
            ),
            player1Name: "Player 1",
            player2Name: "Player 2",
            targetScore: targetScore
        )
        
        // Ensure we're not showing any summaries
        showingGameSummary = false
        showingMatchSummary = false
    }
}

struct BeybladeSelectionView: View {
    @EnvironmentObject var partsStore: PartsStore
    @Binding var selectedBeyblades: [Beyblade]
    @State private var selectedBlade: Part?
    @State private var selectedRatchet: Part?
    @State private var selectedBit: Part?
    @State private var selectedConfiguration: Beyblade?
    
    var body: some View {
        Form {
            Section(header: Text("Selected Beyblades")) {
                if selectedBeyblades.isEmpty {
                    Text("No Beyblades selected")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(selectedBeyblades) { beyblade in
                        HStack {
                            Text(beyblade.name)
                            Spacer()
                            Button(action: {
                                if let index = selectedBeyblades.firstIndex(of: beyblade) {
                                    selectedBeyblades.remove(at: index)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Saved Configurations")) {
                if !partsStore.savedConfigurations.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(partsStore.savedConfigurations) { configuration in
                                Button(action: {
                                    selectedBeyblades.append(configuration)
                                }) {
                                    HStack {
                                        Text(configuration.name)
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Maximum height for 5 items
                } else {
                    Text("No saved configurations")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Custom Configuration")) {
                Picker("Blade", selection: $selectedBlade) {
                    Text("Select Blade").tag(nil as Part?)
                    ForEach(partsStore.getParts(ofType: .blade)) { part in
                        Text(part.name).tag(part as Part?)
                    }
                }
                
                Picker("Ratchet", selection: $selectedRatchet) {
                    Text("Select Ratchet").tag(nil as Part?)
                    ForEach(partsStore.getParts(ofType: .ratchet)) { part in
                        Text(part.name).tag(part as Part?)
                    }
                }
                
                Picker("Bit", selection: $selectedBit) {
                    Text("Select Bit").tag(nil as Part?)
                    ForEach(partsStore.getParts(ofType: .bit)) { part in
                        Text(part.name).tag(part as Part?)
                    }
                }
                
                if let blade = selectedBlade,
                   let ratchet = selectedRatchet,
                   let bit = selectedBit {
                    Button("Add Custom Beyblade") {
                        let beyblade = Beyblade(blade: blade, ratchet: ratchet, bit: bit)
                        selectedBeyblades.append(beyblade)
                        selectedBlade = nil
                        selectedRatchet = nil
                        selectedBit = nil
                    }
                }
            }
        }
        .navigationTitle("Select Beyblades")
    }
}

struct GameSummaryView: View {
    let game: Game
    let onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Final Score")) {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(game.player1Score)")
                                .foregroundColor(.blue)
                            Text("-")
                            Text("\(game.player2Score)")
                                .foregroundColor(.red)
                        }
                        .font(.title)
                        .bold()
                        Spacer()
                    }
                }
                
                Section(header: Text("Scoring History")) {
                    ForEach(game.scoringHistory.indices, id: \.self) { index in
                        let score = game.scoringHistory[index]
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
            .navigationTitle("Game Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continue", action: onContinue)
                }
            }
        }
    }
}

struct MatchSummaryView: View {
    let match: Match
    let onNewMatch: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Match Winner")) {
                    Text(match.winner == 1 ? match.player1Name : match.player2Name)
                        .font(.headline)
                        .foregroundColor(match.winner == 1 ? .blue : .red)
                }
                
                ForEach(match.games) { game in
                    Section(header: Text(gameHeader(for: game))) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Player 1 Info
                            VStack(alignment: .leading) {
                                Text(game.player1Name.isEmpty ? "Player 1" : game.player1Name)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text("Beyblade: \(game.player1Beyblade.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Text("Score: \(game.player1Score)")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            
                            Divider()
                            
                            // Player 2 Info
                            VStack(alignment: .leading) {
                                Text(game.player2Name.isEmpty ? "Player 2" : game.player2Name)
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Text("Beyblade: \(game.player2Beyblade.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Text("Score: \(game.player2Score)")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            // Scoring History
                            VStack(alignment: .leading) {
                                Text("Scoring History")
                                    .font(.headline)
                                ForEach(game.scoringHistory.indices, id: \.self) { index in
                                    let score = game.scoringHistory[index]
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
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Match Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Match", action: onNewMatch)
                }
            }
        }
    }
    
    private func gameHeader(for game: Game) -> String {
        if let index = match.games.firstIndex(of: game) {
            return "Game \(index + 1)"
        }
        return "Game"
    }
}

struct PlayerBeybladePicker: View {
    @EnvironmentObject var partsStore: PartsStore
    @Binding var selectedBeyblade: Beyblade?
    let playerName: String
    let availableBeyblades: [Beyblade]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(60))], spacing: 12) {
                ForEach(availableBeyblades) { beyblade in
                    Button(action: {
                        selectedBeyblade = beyblade
                    }) {
                        VStack(spacing: 4) {
                            Text(beyblade.name)
                                .font(.caption)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                        }
                        .padding(8)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedBeyblade == beyblade ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedBeyblade == beyblade ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
} 