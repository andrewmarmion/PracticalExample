//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct ContentView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationView {
            // iPad view
            if horizontalSizeClass != .compact {
                SideBarView()
                MainView()
                // ViewBuilder gets confused if we don't use an else statement here
            } else {
                MainView()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
