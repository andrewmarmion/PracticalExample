//
//  LoadedView_macOS.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct LoadedView: View {

    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Text(viewModel.selectedList.title)
                .font(.title)
            ListView(items: viewModel.items)
        }
    }
}
