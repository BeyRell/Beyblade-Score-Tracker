import SwiftUI

struct BeybladeBuilderView: View {
    @EnvironmentObject var partsStore: PartsStore
    @State private var selectedBlade: Part?
    @State private var selectedRatchet: Part?
    @State private var selectedBit: Part?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Parts")) {
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
                }
                
                if let blade = selectedBlade,
                   let ratchet = selectedRatchet,
                   let bit = selectedBit {
                    Section(header: Text("Your Beyblade")) {
                        Text("\(blade.name) \(ratchet.name) \(bit.name.components(separatedBy: " ").map { String($0.prefix(1)) }.joined())")
                            .font(.headline)
                        
                        Button("Save Configuration") {
                            let beyblade = Beyblade(blade: blade, ratchet: ratchet, bit: bit)
                            partsStore.saveConfiguration(beyblade)
                        }
                    }
                }
                
                if !partsStore.savedConfigurations.isEmpty {
                    Section(header: Text("Saved Configurations")) {
                        if partsStore.savedConfigurations.isEmpty {
                            Text("No saved configurations")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(partsStore.savedConfigurations) { configuration in
                                Text(configuration.name)
                                    .padding(.vertical, 4)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    partsStore.deleteConfiguration(partsStore.savedConfigurations[index])
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Beyblade Builder")
            .onAppear {
                print("BeybladeBuilderView appeared")
                print("Total parts: \(partsStore.parts.count)")
                print("Parts array contents: \(partsStore.parts)")
            }
        }
    }
} 