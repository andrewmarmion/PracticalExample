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
                EmptyView()
                
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
