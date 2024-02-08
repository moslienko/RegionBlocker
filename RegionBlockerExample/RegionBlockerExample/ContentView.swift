//
//  ContentView.swift
//  RegionBlockerExample
//
//  Created by Pavel Moslienko on 07.02.2024.
//

import SwiftUI
import RegionBlocker

struct ContentView: View {
    
    @State private var viewDidLoad = false
    @State var isAllowed: Bool = false
    
    var body: some View {
        VStack {
            if isAllowed {
                Text("✅ Content for allowed region")
            } else {
                Text("‼️ Content for not allowed region")
            }
        }
        .padding()
        .onAppear {
            if viewDidLoad == false {
                viewDidLoad = true
                checkRegion()
            }
        }
    }
    
    func checkRegion() {
        RegionService.shared.checkRegion { isAllowed in
            self.isAllowed = isAllowed
        }
    }
}

#Preview {
    ContentView()
}
