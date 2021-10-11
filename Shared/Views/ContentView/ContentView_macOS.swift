//
//  ContentView_macOS.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            SideBarView()
            MainView()
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }

    private func toggleSidebar() {
        // This is liable to break, we should be careful about using this.
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
