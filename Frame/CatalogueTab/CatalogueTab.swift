//
//  CatalogueTab.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI

struct CatalogueTab: View {
    
    @ObservedObject private var model: CatalogueModel = .shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Catalogue")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(model.selectedCategoryName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(model.listingItems.count) videos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 5)
            }
            .padding(.bottom, 15)
            
            GalleryGridView(items: model.listingItems)
                .onAppear {
                    WebPImageDecoder.enable()
                    model.fetchIndexIfNecessary()
                }
        }
        .padding([.leading, .trailing], 30)
        .padding(.top, 15)
    }
}

struct CatalogueTab_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueTab()
            .colorScheme(.light)
    }
}
