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
    var isLocal: Bool { get }
}

struct GalleryGridView<Item: GalleryGridItemRepresentable>: UIViewRepresentable {
    
    init(items: [Item],
         selectedItem: Binding<Item?>,
         edgeInsets: UIEdgeInsets = .zero,
         onRefresh: ((@escaping () -> Void)->Void)? = nil) {
        self.items = items
        self.selectedItem = selectedItem
        self.edgeInsets = edgeInsets
        self.onRefresh = onRefresh
    }
    
    let items: [Item]
    let selectedItem: Binding<Item?>
    let edgeInsets: UIEdgeInsets
    let onRefresh: ((@escaping ()->Void)->Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedItem: selectedItem, edgeInsets: edgeInsets, onRefresh: onRefresh)
    }
    
    func makeUIView(context: Context) -> some UIView {
        context.coordinator.collectionView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.items = items
    }
    
    // MARK: GalleryGridCell
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
                    else if !item.isLocal {
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
        lazy var stack: UIStackView = {
            let view = UIStackView(arrangedSubviews: [self.nameLabel, self.sizeLabel])
            view.axis = .vertical
            return view
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
            
//            nameLabel.translatesAutoresizingMaskIntoConstraints = false
//            sizeLabel.translatesAutoresizingMaskIntoConstraints = false
            stack.translatesAutoresizingMaskIntoConstraints = false
            blurView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(blurView)
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
            blurView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -5).isActive = true
            blurView.layer.cornerRadius = 5
            
            blurView.contentView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 5).isActive = true
            stack.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor).isActive = true
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 5).isActive = true
            stack.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("Not implemented!")
        }
    }
    
    // MARK: Coordinator
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
        enum Section { case main }
        
        private let selectedItem: Binding<Item?>
        private let onRefresh: ((@escaping () -> Void) -> Void)?
        
        /// The collectionView.
        lazy var collectionView: UICollectionView = {
            let cView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            cView.register(GalleryGridCell.self, forCellWithReuseIdentifier: "galleryCell")
            cView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
            cView.delegate = self
            cView.backgroundColor = .systemBackground
            cView.keyboardDismissMode = .interactive
            if self.onRefresh != nil {
                cView.refreshControl = refreshControl
            }
            return cView
        }()
        
        lazy var refreshControl: UIRefreshControl = {
            let control = UIRefreshControl()
            control.addTarget(self, action: #selector(performRefresh(_:)), for: .valueChanged)
            return control
        }()
        
        lazy var searchBar: UISearchBar = {
            let bar = UISearchBar()
            bar.delegate = self
            bar.tintColor = UIColor(named: "AccentColor")
            bar.placeholder = "Name"
            bar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return bar
        }()
        
        var items = [Item]() {
            didSet {
                updateSnapshot()
            }
        }
        
        var filterActive = false
        var filteredItems: [Item] {
            searchBar.text.flatMap { text in
                items.filter {
                    $0.name.contains(text)
                }
            } ?? items
        }
        
        /// The diffable datasource.
        lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath) as! GalleryGridCell
            cell.item = item
            return cell
        }
        
        init(selectedItem: Binding<Item?>,
             edgeInsets: UIEdgeInsets,
             onRefresh: ((@escaping () -> Void)->Void)?) {
            self.selectedItem = selectedItem
            self.onRefresh = onRefresh
            super.init()
            dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath)
                self.searchBar.frame = header.bounds
                header.addSubview(self.searchBar)
                return header
            }
            self.collectionView.dataSource = dataSource
            self.collectionView.contentInset = edgeInsets
        }
        
        @objc private func performRefresh(_ event: UIEvent) {
            if let handler = self.onRefresh {
                handler {
                    self.refreshControl.endRefreshing()
                    UIView.animate(withDuration: 0.2) {
                        self.collectionView.contentOffset.y = 0
                    }
                }
            }
            else {
                refreshControl.endRefreshing()
            }
        }
        
        func updateSnapshot() {
            DispatchQueue.main.async {
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self.filterActive ? self.filteredItems:self.items)
                self.dataSource.apply(snapshot)
            }
        }
        
        // MARK: UICollectionViewDelegate
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let columns: CGFloat = 2
            let spacing: CGFloat = 20
            let aspectRatio: CGFloat = 903 / 507
            let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
            let width = (availableWidth - (columns-1) * spacing) / columns
            return .init(width: width, height: width * aspectRatio)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            20
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            .init(top: 20, left: 0, bottom: 0, right: 0)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            CGSize(width: collectionView.frame.width, height: 40)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            collectionView.deselectItem(at: indexPath, animated: false)
            selectedItem.wrappedValue = dataSource.itemIdentifier(for: indexPath)
        }
        
        // MARK: UISearchBarDelegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            filterActive = !searchText.isEmpty
            updateSnapshot()
        }
    }
    
}
