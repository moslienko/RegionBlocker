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
    @State var isBlocked: Bool = false
    
    var body: some View {
        VStack {
            if isBlocked {
                Text("Content for blocked region")
            } else {
                Text("Content for non blocked region")
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
        RegionService.shared.checkRegion { isBlocked in
            self.isBlocked = isBlocked
        }
    }
}

#Preview {
    ContentView()
}
