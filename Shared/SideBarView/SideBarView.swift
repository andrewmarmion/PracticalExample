//
//  SideBarView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct SideBarView: View {

    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        List {
            ForEach(SelectedList.allCases) { item in
                HStack {
                    Text(item.rawValue.capitalized)
                        .foregroundColor(viewModel.selectedList == item ? .blue : nil)
                    Spacer()
                    // This makes the text tappable across the whole view
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedList = item
                }
            }
        }
        .navigationTitle("Options")
    }
}
