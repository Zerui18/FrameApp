//
//  GalleryGridView.swift
//  Frame
//
//  Created by Zerui Chen on 31/7/21.
//

import UIKit
import SwiftUI
import Nuke
import NVActivityIndicatorView

protocol GalleryGridItemRepresentable: Identifiable, Hashable {
    var name: String { get }
    var sizeString: String { get }
    var image: UIImage? { get }
    var imageURL: URL { get }
    var videoURL: URL { get }
}

struct GalleryGridView<Item: GalleryGridItemRepresentable>: UIViewRepresentable {
    
    fileprivate class GalleryGridCell: UICollectionViewCell {
        
        var item: Item! {
            didSet {
                if item != nil {
                    nameLabel.text = item.name
                    sizeLabel.text = item.sizeString
                    if let image = item.image {
                        // Cancel outstanding requests & directly set iamge.
                        Nuke.cancelRequest(for: thumbnailImageView)
                        loadingIndicator.stopAnimating()
                        thumbnailImageView.image = image
                    }
                    else {
                        // Load image from URL.
                        loadingIndicator.startAnimating()
                        Nuke.loadImage(with: item.imageURL,
                                       options: .init(transition: .fadeIn(duration: 0.3)),
                                       into: thumbnailImageView) { _ in
                            self.loadingIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        
        // MARK: Subviews
        let nameLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        let sizeLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        let blurView: UIVisualEffectView = {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            view.layer.masksToBounds = true
            return view
        }()
        let thumbnailImageView: UIImageView = {
            let view = UIImageView()
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 10
            view.backgroundColor = .tertiarySystemFill
            return view
        }()
        let loadingIndicator: NVActivityIndicatorView = {
            let view = NVActivityIndicatorView(frame: .zero, type: .pacman, color: .init(named: "AccentColor"))
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            // Layout.
            thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            thumbnailImageView.frame = contentView.bounds
            contentView.addSubview(thumbnailImageView)
            
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingIndicator)
            loadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            sizeLabel.translatesAutoresizingMaskIntoConstraints = false
            blurView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(blurView)
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
            blurView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -5).isActive = true
            blurView.layer.cornerRadius = 5
            
            blurView.contentView.addSubview(nameLabel)
            blurView.contentView.addSubview(sizeLabel)
            nameLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 5).isActive = true
            nameLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor).isActive = true
            nameLabel.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 5).isActive = true
            sizeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
            sizeLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 5).isActive = true
            sizeLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor).isActive = true
            sizeLabel.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -5).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("Not implemented!")
        }
    }
    
    let items: [Item]
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        enum Section { case main }
        
        /// The collectionView.
        lazy var collectionView: UICollectionView = {
            let cView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            cView.register(GalleryGridCell.self, forCellWithReuseIdentifier: "galleryCell")
            cView.delegate = self
            cView.backgroundColor = .systemBackground
            cView.showsVerticalScrollIndicator = false
            return cView
        }()
        
        /// The diffable datasource.
        lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GalleryGridCell
            cell.item = item
            return cell
        }
        
        override init() {
            super.init()
            self.collectionView.dataSource = dataSource
        }
        
        func updateSnapshot(with items: [Item]) {
            DispatchQueue.main.async {
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items)
                self.dataSource.apply(snapshot)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let columns: CGFloat = 2
            let spacing: CGFloat = 20
            let aspectRatio: CGFloat = 903 / 507
            let width = (collectionView.bounds.width - (columns-1) * spacing) / columns
            return .init(width: width, height: width * aspectRatio)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            20
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> some UIView {
        context.coordinator.collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.updateSnapshot(with: items)
    }
    
}
