//
//  MainPanel.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import SwiftUI

struct MainPanel: View {
    
    @ObservedObject var model = MainPanelModel()
    
    var body: some View {
        VideoView(videoPath: $model.videoPathShared)
    }
}

struct MainPanel_Previews: PreviewProvider {
    static var previews: some View {
        MainPanel()
    }
}
