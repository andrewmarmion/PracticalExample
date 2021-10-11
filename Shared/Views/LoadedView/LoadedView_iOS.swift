//
//  LoadedView_iOS.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct LoadedView: View {

    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                Picker("", selection: $viewModel.selectedList) {
                    ForEach(SelectedList.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }

            ListView(items: viewModel.items)
        }
    }
}
