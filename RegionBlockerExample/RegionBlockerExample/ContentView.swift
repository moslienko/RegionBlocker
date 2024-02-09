//
//  ContentView.swift
//  RegionBlockerExample
//
//  Created by Pavel Moslienko on 07.02.2024.
//

import SwiftUI
import RegionBlocker
import CoreLocation

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
                //checkRegion()
                
                Task {
                    await asyncCheckRegion()
                }
            }
        }
    }
    
    func checkRegion() {
        RegionService.shared.allowedRegions = [CountryCode.Russia.rawValue, CountryCode.Belarus.rawValue]
        RegionService.shared.allowedLanguages = ["ru", "be"]
        RegionService.shared.checkMethods = RegionBlockerMethod.allCases
        
        RegionService.shared.checkRegion { isAllowed in
            self.isAllowed = isAllowed
        }
    }
    
    func asyncCheckRegion() async {
        RegionService.shared.allowedRegions = [CountryCode.Russia.rawValue, CountryCode.Belarus.rawValue]
        RegionService.shared.allowedLanguages = ["ru", "be"]
        RegionService.shared.checkMethods = [.byLocation]
        
        self.isAllowed = await RegionService.shared.checkRegion(location: CLLocation(latitude: 55.7558, longitude: 37.6173))
    }
}

#Preview {
    ContentView()
}
