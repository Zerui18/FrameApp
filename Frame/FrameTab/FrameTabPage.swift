//
//  FrameTabPage.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData

struct FrameTabPage: View {
    
    let domain: SettingDomain
    
    init(domain: SettingDomain) {
        self.domain = domain
        self.model = .init(domain: domain)
    }
    
    @ObservedObject private var model: FrameTabPageModel
    @State private var isLibraryOpened = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                ParallexCropView()
                    .environmentObject(model)
                
                Spacer()
                
                Button {
                    isLibraryOpened = true
                } label: {
                    Text("Choose Video")
                        .bold()
                        .foregroundColor(Color(.white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill()
                        )
                }
                .sheet(isPresented: $isLibraryOpened) {
                    LibraryView(domain: domain)
                        .environment(\.managedObjectContext, persistentContainer.viewContext)
                }
            }
            .padding([.leading, .trailing], 30)
            .padding([.top, .bottom], 15)
        }
    }
}

struct FrameTabPage_Previews: PreviewProvider {
    static var previews: some View {
        FrameTabPage(domain: .homescreen)
    }
}
