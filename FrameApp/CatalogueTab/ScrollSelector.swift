//
//  ScrollSelector.swift
//  FrameApp
//
//  Created by Zerui Chen on 19/11/21.
//

import SwiftUI

struct ScrollSelector: View {
    
    let items: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(zip(0..<items.count, items)), id: \.1) { index, item in
                    Text(item)
                        .font(.subheadline)
                        .frame(minWidth: 40)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(.secondarySystemFill))
                                .opacity(selectedIndex == index ? 1:0)
                        )
                        .onTapGesture {
                            if selectedIndex != index {
                                selectedIndex = index
                            }
                        }
                        .animation(.easeIn)
                }
            }
        }
    }
}

struct ScrollSelector_Previews: PreviewProvider {
    static var previews: some View {
        ScrollSelector(items: ["a", "b", "c"], selectedIndex: .constant(0))
    }
}
