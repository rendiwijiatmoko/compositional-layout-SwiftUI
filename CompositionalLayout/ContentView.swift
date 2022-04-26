//
//  ContentView.swift
//  CompositionalLayout
//
//  Created by Rendi Wijiatmoko on 26/04/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                // MARK: Custom View
                CompositionalView(items: 1...55, id: \.self) { item in
                    ZStack {
                        Rectangle()
                            .fill(.gray)
                        Text("\(item)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
