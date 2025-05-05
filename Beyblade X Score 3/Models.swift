import Foundation

// MARK: - Part Types
enum PartType: String, CaseIterable, Codable {
    case blade
    case ratchet
    case bit
}

// MARK: - Part Model
struct Part: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let type: PartType
    
    init(id: UUID = UUID(), name: String, type: PartType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Part, rhs: Part) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Beyblade Model
struct Beyblade: Identifiable, Codable, Hashable {
    let id: UUID
    let blade: Part
    let ratchet: Part
    let bit: Part
    
    var name: String {
        let bitAbbreviation = bit.name.components(separatedBy: " ")
            .map { String($0.prefix(1)) }
            .joined()
        return "\(blade.name) \(ratchet.name) \(bitAbbreviation)"
    }
    
    init(id: UUID = UUID(), blade: Part, ratchet: Part, bit: Part) {
        self.id = id
        self.blade = blade
        self.ratchet = ratchet
        self.bit = bit
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Beyblade, rhs: Beyblade) -> Bool {
        lhs.id == rhs.id &&
        lhs.blade == rhs.blade &&
        lhs.ratchet == rhs.ratchet &&
        lhs.bit == rhs.bit
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case blade
        case ratchet
        case bit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        blade = try container.decode(Part.self, forKey: .blade)
        ratchet = try container.decode(Part.self, forKey: .ratchet)
        bit = try container.decode(Part.self, forKey: .bit)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(blade, forKey: .blade)
        try container.encode(ratchet, forKey: .ratchet)
        try container.encode(bit, forKey: .bit)
    }
}

// MARK: - Scoring Types
enum ScoringType: String, CaseIterable, Codable {
    case spinFinish = "Spin Finish"
    case overFinish = "Over Finish"
    case burstFinish = "Burst Finish"
    case xtremeFinish = "X-treme Finish"
    
    var points: Int {
        switch self {
        case .spinFinish: return 1
        case .overFinish, .burstFinish: return 2
        case .xtremeFinish: return 3
        }
    }
}

// MARK: - Scoring History Entry
struct ScoringHistoryEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let player: Int
    let type: ScoringType
    let beyblade: Beyblade
    
    init(id: UUID = UUID(), player: Int, type: ScoringType, beyblade: Beyblade) {
        self.id = id
        self.player = player
        self.type = type
        self.beyblade = beyblade
    }
}

// MARK: - Game Model
struct Game: Identifiable, Codable, Equatable {
    let id: UUID
    var player1Beyblade: Beyblade
    var player2Beyblade: Beyblade
    let player1Name: String
    let player2Name: String
    let targetScore: Int
    var player1Score: Int = 0
    var player2Score: Int = 0
    var scoringHistory: [ScoringHistoryEntry] = []
    var winner: Int? = nil
    
    init(id: UUID = UUID(), 
         player1Beyblade: Beyblade, 
         player2Beyblade: Beyblade,
         player1Name: String = "Player 1",
         player2Name: String = "Player 2",
         targetScore: Int) {
        self.id = id
        self.player1Beyblade = player1Beyblade
        self.player2Beyblade = player2Beyblade
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.targetScore = targetScore
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id &&
        lhs.player1Beyblade == rhs.player1Beyblade &&
        lhs.player2Beyblade == rhs.player2Beyblade &&
        lhs.player1Name == rhs.player1Name &&
        lhs.player2Name == rhs.player2Name &&
        lhs.targetScore == rhs.targetScore &&
        lhs.player1Score == rhs.player1Score &&
        lhs.player2Score == rhs.player2Score &&
        lhs.winner == rhs.winner &&
        lhs.scoringHistory == rhs.scoringHistory
    }
}

// MARK: - Match Model
struct Match: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let player1Name: String
    let player2Name: String
    let player1Beyblades: [Beyblade]
    let player2Beyblades: [Beyblade]
    var games: [Game]
    let targetScore: Int
    var winner: Int? = nil
    let isSimpleMatch: Bool
    
    init(id: UUID = UUID(),
         player1Name: String = "Player 1",
         player2Name: String = "Player 2",
         player1Beyblades: [Beyblade],
         player2Beyblades: [Beyblade],
         targetScore: Int,
         isSimpleMatch: Bool = false) {
        self.id = id
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.player1Beyblades = player1Beyblades
        self.player2Beyblades = player2Beyblades
        self.games = []
        self.targetScore = targetScore
        self.isSimpleMatch = isSimpleMatch
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case player1Name
        case player2Name
        case player1Beyblades
        case player2Beyblades
        case games
        case targetScore
        case winner
        case isSimpleMatch
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        player1Name = try container.decode(String.self, forKey: .player1Name)
        player2Name = try container.decode(String.self, forKey: .player2Name)
        player1Beyblades = try container.decode([Beyblade].self, forKey: .player1Beyblades)
        player2Beyblades = try container.decode([Beyblade].self, forKey: .player2Beyblades)
        games = try container.decode([Game].self, forKey: .games)
        targetScore = try container.decode(Int.self, forKey: .targetScore)
        winner = try container.decodeIfPresent(Int.self, forKey: .winner)
        isSimpleMatch = try container.decode(Bool.self, forKey: .isSimpleMatch)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(player1Name, forKey: .player1Name)
        try container.encode(player2Name, forKey: .player2Name)
        try container.encode(player1Beyblades, forKey: .player1Beyblades)
        try container.encode(player2Beyblades, forKey: .player2Beyblades)
        try container.encode(games, forKey: .games)
        try container.encode(targetScore, forKey: .targetScore)
        try container.encodeIfPresent(winner, forKey: .winner)
        try container.encode(isSimpleMatch, forKey: .isSimpleMatch)
    }
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id &&
        lhs.player1Name == rhs.player1Name &&
        lhs.player2Name == rhs.player2Name &&
        lhs.player1Beyblades == rhs.player1Beyblades &&
        lhs.player2Beyblades == rhs.player2Beyblades &&
        lhs.games == rhs.games &&
        lhs.targetScore == rhs.targetScore &&
        lhs.winner == rhs.winner &&
        lhs.isSimpleMatch == rhs.isSimpleMatch
    }
}

// MARK: - Match History Model
class MatchHistory: ObservableObject, Codable {
    @Published var matches: [Match] = []
    private let defaults = UserDefaults.standard
    private let matchesKey = "savedMatches"
    
    init(matches: [Match] = []) {
        self.matches = matches
        loadMatches()
    }
    
    func addMatch(_ match: Match) {
        // Only add non-simple matches to history
        if !match.isSimpleMatch {
            // Check if this match already exists in the history
            if !matches.contains(where: { $0.id == match.id }) {
                matches.insert(match, at: 0)
                if matches.count > 20 {
                    matches.removeLast()
                }
                saveMatches()
            }
        }
    }
    
    private func loadMatches() {
        if let data = defaults.data(forKey: matchesKey) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([Match].self, from: data)
                // Filter out any simple matches that might have been saved
                // and ensure no duplicates by using Set
                let uniqueMatches = Array(Set(decoded.filter { !$0.isSimpleMatch }))
                matches = uniqueMatches.sorted { $0.id.uuidString > $1.id.uuidString } // Sort by ID to maintain order
                print("=== LOADED MATCHES ===")
                for match in matches {
                    print("Match ID: \(match.id)")
                    print("Is Simple Match: \(match.isSimpleMatch)")
                    for game in match.games {
                        print("  Game ID: \(game.id)")
                        print("  Scoring History:")
                        for score in game.scoringHistory {
                            print("    - Player \(score.player): \(score.type.rawValue) with \(score.beyblade.name)")
                        }
                    }
                }
                print("=====================")
            } catch {
                print("Error decoding matches: \(error)")
            }
        }
    }
    
    private func saveMatches() {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(matches)
            defaults.set(encoded, forKey: matchesKey)
            print("=== SAVED MATCHES ===")
            for match in matches {
                print("Match ID: \(match.id)")
                print("Is Simple Match: \(match.isSimpleMatch)")
                for game in match.games {
                    print("  Game ID: \(game.id)")
                    print("  Scoring History:")
                    for score in game.scoringHistory {
                        print("    - Player \(score.player): \(score.type.rawValue) with \(score.beyblade.name)")
                    }
                }
            }
            print("=====================")
        } catch {
            print("Error encoding matches: \(error)")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case matches
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        matches = try container.decode([Match].self, forKey: .matches)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matches, forKey: .matches)
    }
}

// MARK: - Matchup Statistics
struct MatchResult: Hashable {
    let beyblade1: String
    let beyblade2: String
    
    init(_ beyblade1: String, _ beyblade2: String) {
        self.beyblade1 = beyblade1
        self.beyblade2 = beyblade2
    }
}

struct MatchupStats {
    let wins: Int
    let losses: Int
    let scoringTypeCounts: [ScoringType: Int]
    let scoringTypeAgainst: [ScoringType: Int]
    
    var winPercentage: Double {
        guard wins + losses > 0 else { return 0 }
        return Double(wins) / Double(wins + losses)
    }
    
    func scoringTypePercentage(for type: ScoringType) -> Double {
        let total = scoringTypeCounts.values.reduce(0, +)
        guard total > 0 else { return 0 }
        return Double(scoringTypeCounts[type] ?? 0) / Double(total)
    }
    
    func scoringTypeAgainstPercentage(for type: ScoringType) -> Double {
        let total = scoringTypeAgainst.values.reduce(0, +)
        guard total > 0 else { return 0 }
        return Double(scoringTypeAgainst[type] ?? 0) / Double(total)
    }
}

// MARK: - Parts Store
class PartsStore: ObservableObject {
    @Published var parts: [Part] = []
    @Published var savedConfigurations: [Beyblade] = []
    private let defaults = UserDefaults.standard
    private let configurationsKey = "savedConfigurations"
    
    init() {
        loadConfigurations()
    }
    
    func addPart(_ part: Part) {
        parts.append(part)
    }
    
    func getParts(ofType type: PartType) -> [Part] {
        parts.filter { $0.type == type }
    }
    
    func saveConfiguration(_ beyblade: Beyblade) {
        if !savedConfigurations.contains(where: { $0.id == beyblade.id }) {
            savedConfigurations.append(beyblade)
            saveConfigurations()
        }
    }
    
    func deleteConfiguration(_ beyblade: Beyblade) {
        savedConfigurations.removeAll { $0.id == beyblade.id }
        saveConfigurations()
    }
    
    func getConfigurations() -> [Beyblade] {
        savedConfigurations
    }
    
    private func loadConfigurations() {
        if let data = defaults.data(forKey: configurationsKey) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode([Beyblade].self, from: data)
                savedConfigurations = decoded
                print("=== LOADED CONFIGURATIONS ===")
                for config in savedConfigurations {
                    print("Configuration: \(config.name)")
                }
                print("=====================")
            } catch {
                print("Error decoding configurations: \(error)")
            }
        }
    }
    
    private func saveConfigurations() {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(savedConfigurations)
            defaults.set(encoded, forKey: configurationsKey)
            print("=== SAVED CONFIGURATIONS ===")
            for config in savedConfigurations {
                print("Configuration: \(config.name)")
            }
            print("=====================")
        } catch {
            print("Error encoding configurations: \(error)")
        }
    }
}

// MARK: - Sample Parts
extension PartsStore {
    static let sampleParts: [Part] = [
        // Blades
        Part(name: "AeroPegasus", type: .blade),
        Part(name: "Bite Croc", type: .blade),
        Part(name: "BlackShell", type: .blade),
        Part(name: "Captain America", type: .blade),
        Part(name: "CobaltDragoon", type: .blade),
        Part(name: "CobaltDrake", type: .blade),
        Part(name: "CrimsonGaruda", type: .blade),
        Part(name: "Darth Vader", type: .blade),
        Part(name: "DracielShield", type: .blade),
        Part(name: "DragoonStorm", type: .blade),
        Part(name: "DranBuster", type: .blade),
        Part(name: "DranDagger", type: .blade),
        Part(name: "DranSword", type: .blade),
        Part(name: "DranzerSpiral", type: .blade),
        Part(name: "DrigerSlash", type: .blade),
        Part(name: "General Grievous", type: .blade),
        Part(name: "GhostCircle", type: .blade),
        Part(name: "Gill Shark", type: .blade),
        Part(name: "GolemRock", type: .blade),
        Part(name: "HellsChain", type: .blade),
        Part(name: "HellsHammer", type: .blade),
        Part(name: "HellsScythe", type: .blade),
        Part(name: "Hover Wyvern", type: .blade),
        Part(name: "ImpactDrake", type: .blade),
        Part(name: "Iron Man", type: .blade),
        Part(name: "Knife Shinobi", type: .blade),
        Part(name: "KnightLance", type: .blade),
        Part(name: "KnightMail", type: .blade),
        Part(name: "KnightShield", type: .blade),
        Part(name: "LeonClaw", type: .blade),
        Part(name: "LeonCrest", type: .blade),
        Part(name: "Lightning L-Drago (Rapid-Hit Type)", type: .blade),
        Part(name: "Lightning L-Drago (Upper Type)", type: .blade),
        Part(name: "Luke Skywalker", type: .blade),
        Part(name: "Megatron", type: .blade),
        Part(name: "Moff Gideon", type: .blade),
        Part(name: "Mosasaurus", type: .blade),
        Part(name: "Obi-Wan Kenobi", type: .blade),
        Part(name: "Optimus Primal", type: .blade),
        Part(name: "Optimus Prime", type: .blade),
        Part(name: "PhoenixFeather", type: .blade),
        Part(name: "PhoenixRudder", type: .blade),
        Part(name: "PhoenixWing", type: .blade),
        Part(name: "Quetzalcoatlus", type: .blade),
        Part(name: "Red Hulk", type: .blade),
        Part(name: "RhinoHorn", type: .blade),
        Part(name: "Roar Tyranno", type: .blade),
        Part(name: "SamuraiSaber", type: .blade),
        Part(name: "Savage Bear", type: .blade),
        Part(name: "ScorpioSpear", type: .blade),
        Part(name: "SharkEdge", type: .blade),
        Part(name: "ShelterDrake", type: .blade),
        Part(name: "ShinobiShadow", type: .blade),
        Part(name: "SilverWolf", type: .blade),
        Part(name: "SphinxCowl", type: .blade),
        Part(name: "Spider-Man", type: .blade),
        Part(name: "Spinosaurus", type: .blade),
        Part(name: "Starscream", type: .blade),
        Part(name: "Steel Samurai", type: .blade),
        Part(name: "StormPegasis", type: .blade),
        Part(name: "T. Rex", type: .blade),
        Part(name: "Talon Ptera", type: .blade),
        Part(name: "Thanos", type: .blade),
        Part(name: "The Mandalorian", type: .blade),
        Part(name: "Trypio", type: .blade),
        Part(name: "Tusk Mammoth", type: .blade),
        Part(name: "TyrannoBeat", type: .blade),
        Part(name: "UnicornSting", type: .blade),
        Part(name: "Venom", type: .blade),
        Part(name: "VictoryValkyrie", type: .blade),
        Part(name: "ViperTail", type: .blade),
        Part(name: "WeissTiger", type: .blade),
        Part(name: "WhaleWave", type: .blade),
        Part(name: "WizardArrow", type: .blade),
        Part(name: "WizardRod", type: .blade),
        Part(name: "WyvernGale", type: .blade),
        Part(name: "XenoXcalibur", type: .blade),
        Part(name: "Yell Kong", type: .blade),
        
        // Ratchets
        Part(name: "0-70", type: .ratchet),
        Part(name: "0-80", type: .ratchet),
        Part(name: "1-60", type: .ratchet),
        Part(name: "1-80", type: .ratchet),
        Part(name: "2-60", type: .ratchet),
        Part(name: "2-70", type: .ratchet),
        Part(name: "2-80", type: .ratchet),
        Part(name: "3-60", type: .ratchet),
        Part(name: "3-70", type: .ratchet),
        Part(name: "3-80", type: .ratchet),
        Part(name: "3-85", type: .ratchet),
        Part(name: "4-55", type: .ratchet),
        Part(name: "4-60", type: .ratchet),
        Part(name: "4-70", type: .ratchet),
        Part(name: "4-80", type: .ratchet),
        Part(name: "5-60", type: .ratchet),
        Part(name: "5-70", type: .ratchet),
        Part(name: "5-80", type: .ratchet),
        Part(name: "6-60", type: .ratchet),
        Part(name: "6-80", type: .ratchet),
        Part(name: "7-60", type: .ratchet),
        Part(name: "7-70", type: .ratchet),
        Part(name: "7-80", type: .ratchet),
        Part(name: "9-60", type: .ratchet),
        Part(name: "9-70", type: .ratchet),
        Part(name: "9-80", type: .ratchet),
        
        // Bits
        Part(name: "Ball", type: .bit),
        Part(name: "Flat", type: .bit),
        Part(name: "Needle", type: .bit),
        Part(name: "Point", type: .bit),
        Part(name: "Rush", type: .bit),
        Part(name: "Spike", type: .bit),
        Part(name: "Taper", type: .bit),
        Part(name: "Accel", type: .bit),
        Part(name: "Bound Spike", type: .bit),
        Part(name: "Cyclone", type: .bit),
        Part(name: "Disk Ball", type: .bit),
        Part(name: "Dot", type: .bit),
        Part(name: "Elevate", type: .bit),
        Part(name: "Free Ball", type: .bit),
        Part(name: "Gear Ball", type: .bit),
        Part(name: "Gear Flat", type: .bit),
        Part(name: "Gear Needle", type: .bit),
        Part(name: "Gear Point", type: .bit),
        Part(name: "Gear Rush", type: .bit),
        Part(name: "Glide", type: .bit),
        Part(name: "Hexa", type: .bit),
        Part(name: "High Needle", type: .bit),
        Part(name: "High Taper", type: .bit),
        Part(name: "Kick", type: .bit),
        Part(name: "Level", type: .bit),
        Part(name: "Low Flat", type: .bit),
        Part(name: "Low Orb", type: .bit),
        Part(name: "Low Rush", type: .bit),
        Part(name: "Metal Needle", type: .bit),
        Part(name: "Orb", type: .bit),
        Part(name: "Quake", type: .bit),
        Part(name: "Rubber Accel", type: .bit),
        Part(name: "Trans Point", type: .bit),
        Part(name: "Under Needle", type: .bit),
        Part(name: "Unite", type: .bit),
        Part(name: "Vortex", type: .bit),
        Part(name: "Wedge", type: .bit),
        Part(name: "Zap", type: .bit)
    ]
    
    static let permanentConfigurations: [Beyblade] = [
        Beyblade(
            blade: Part(name: "DranBuster", type: .blade),
            ratchet: Part(name: "1-60", type: .ratchet),
            bit: Part(name: "Flat", type: .bit)
        ),
        Beyblade(
            blade: Part(name: "GolemRock", type: .blade),
            ratchet: Part(name: "6-60", type: .ratchet),
            bit: Part(name: "Low Rush", type: .bit)
        ),
        Beyblade(
            blade: Part(name: "SilverWolf", type: .blade),
            ratchet: Part(name: "3-60", type: .ratchet),
            bit: Part(name: "High Needle", type: .bit)
        ),
        Beyblade(
            blade: Part(name: "CobaltDragoon", type: .blade),
            ratchet: Part(name: "3-60", type: .ratchet),
            bit: Part(name: "Elevate", type: .bit)
        ),
        Beyblade(
            blade: Part(name: "WizardRod", type: .blade),
            ratchet: Part(name: "3-60", type: .ratchet),
            bit: Part(name: "Bound Spike", type: .bit)
        ),
        Beyblade(
            blade: Part(name: "ImpactDrake", type: .blade),
            ratchet: Part(name: "4-70", type: .ratchet),
            bit: Part(name: "Level", type: .bit)
        )
    ]
    
    func loadSampleParts() {
        parts = PartsStore.sampleParts
        
        // Only add permanent configurations if none exist
        if savedConfigurations.isEmpty {
            savedConfigurations = PartsStore.permanentConfigurations
            saveConfigurations()
        }
    }
} 