//
//  ProgressBar.swift
//  Biu
//
//  Created by Zerui Chen on 12/7/20.
//

import SwiftUI

struct ProgressBar: View {
    
    var value: Double
    var maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(.systemFill))
                
                let perc = CGFloat(self.value) / max(CGFloat(self.maxValue), 0.1)
                Rectangle()
                    .frame(width: min(perc * geometry.size.width, geometry.size.width),
                           height: geometry.size.height)
                    .foregroundColor(.accentColor)
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(value: 0.3, maxValue: 1)
    }
}
