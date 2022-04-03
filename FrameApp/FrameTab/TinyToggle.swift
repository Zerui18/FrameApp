//
//  TinyToggle.swift
//  FrameApp
//
//  Created by Zerui Chen on 5/1/22.
//

import SwiftUI

struct TinyToggle: View {
    
    @Setting private var value: Bool
    
    private let onImage: Image
    private let offImage: Image
    
    init(setting: Setting<Bool>,
         onImage: Image,
         offImage: Image) {
        _value = setting
        self.onImage = onImage
        self.offImage = offImage
    }
    
    var body: some View {
        let image = value ? onImage:offImage
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding(10)
            .background(
                Blur(style: .regular)
                    .cornerRadius(10)
            )
            .onTapGesture {
                value.toggle()
            }
    }
}

//struct TinyToggle_Previews: PreviewProvider {
//    static var previews: some View {
//        TinyToggle()
//    }
//}
