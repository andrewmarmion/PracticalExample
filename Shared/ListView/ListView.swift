//
//  ListView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct ListView: View {
    let items: [DisplayItem]

    var body: some View {
        List {
            ForEach(items) { item in
                ListItem(item: item)
            }
        }
    }
}
