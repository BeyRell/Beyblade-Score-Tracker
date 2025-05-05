import SwiftUI

struct PartsListView: View {
    @EnvironmentObject var partsStore: PartsStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(PartType.allCases, id: \.self) { type in
                    Section(header: Text(type.rawValue.capitalized)) {
                        let parts = partsStore.getParts(ofType: type)
                        ForEach(parts) { part in
                            Text(part.name)
                        }
                    }
                }
            }
            .navigationTitle("Parts List")
            .onAppear {
                print("PartsListView appeared")
                print("Total parts: \(partsStore.parts.count)")
                print("Parts array contents: \(partsStore.parts)")
                for type in PartType.allCases {
                    let parts = partsStore.getParts(ofType: type)
                    print("Parts of type \(type): \(parts.count)")
                }
            }
        }
    }
} 