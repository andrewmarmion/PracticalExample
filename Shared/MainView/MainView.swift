//
//  MainView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .empty:
                // Using an empty view here causes the onAppear to not be called on iOS
                Rectangle()
                    .opacity(0.1)

            case .error(let error):
                ErrorView(error: error)

            case .loaded:
                LoadedView()

            case .loading:
                LoadingView()
            }
        }
        .navigationTitle("Courses")
        .toolbar {
            Button {
                viewModel.load()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
