//
//  PracticalExampleApp.swift
//  Shared
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

@main
struct PracticalExampleApp: App {

    let viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .commands {
            SidebarCommands()
        }

    }
}
