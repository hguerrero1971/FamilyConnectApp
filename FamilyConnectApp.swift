//
//  FamilyConnectApp.swift
//  FamilyConnect
//
//  Created by Hugo Guerrero on 10/29/23.
//

import SwiftUI

@main
struct FamilyConnectApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
    }
}
