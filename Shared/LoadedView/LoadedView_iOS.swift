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
                        Text(item.rawValue.capitalized).tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            ListView(items: viewModel.items)
        }
    }
}
