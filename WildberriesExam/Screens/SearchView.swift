//
//  SearchView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                SearchBarView(searchText: $searchText, onSubmit: { print("submit") })
                    .padding()
                Spacer()
            }
        }
    }
}
