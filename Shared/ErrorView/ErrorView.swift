//
//  ErrorView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct ErrorView: View {

    let error: Error

    var body: some View {
        Text("Loading error \(error.localizedDescription)")
            .padding()
    }
}
