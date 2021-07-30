//
//  CatalogueTab.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import QGrid

struct CatalogueTab: View {
    
    @ObservedObject private var model: CatalogueModel = .shared
    
    var body: some View {
        VStack {
            if model.listingItems.isEmpty {
                Text("Loading Index...")
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                    .onAppear {
                        model.fetchIndexIfNecessary()
                    }
            }
            else {
                QGrid(model.listingItems, columns: 2) { item in
                    ZStack(alignment: .init(horizontal: .leading, vertical: .bottom)) {
                        AsyncImage(url: item.imageURL) {
                            Text("loading")
                        } image: {
                            Image(uiImage: $0)
                                .resizable()
                        }
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
//
//                        VStack(alignment: .leading) {
//                            Text(item.name)
//                                .font(.caption)
//
//                            Text(item.size)
//                                .font(.caption)
//                        }
//                        .padding(5)
//                        .background(Blur().cornerRadius(5))
//                        .padding([.leading, .bottom], 5)
                    }
                    .frame(minWidth: 100, minHeight: 100)
                }
            }
        }
    }
}

struct CatalogueTab_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueTab()
    }
}
