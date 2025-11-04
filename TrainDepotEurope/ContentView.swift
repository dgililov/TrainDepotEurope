//
//  ContentView.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                MainMenuView()
            } else {
                NameEntryView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationService.shared)
    }
}

