//
//  ViewController.swift
//  MarvelAPI
//
//  Created by adrian.a.fernandez on 11/10/2018.
//  Copyright © 2018 adrian.a.fernandez. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON
import Alamofire
import CommonCrypto

open class DiscardableImageCacheItem: NSObject, NSDiscardableContent {
    
    private(set) public var image: UIImage?
    var accessCount: UInt = 0
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public func beginContentAccess() -> Bool {
        if image == nil {
            return false
        }
        
        accessCount += 1
        return true
    }
    
    public func endContentAccess() {
        if accessCount > 0 {
            accessCount -= 1
        }
    }
    
    public func discardContentIfPossible() {
        if accessCount == 0 {
            image = nil
        }
    }
    
    public func isContentDiscarded() -> Bool {
        return image == nil
    }
    
}

open class CachedImageView: UIImageView {
    
    public static let imageCache = NSCache<NSString, DiscardableImageCacheItem>()
    
    open var shouldUseEmptyImage = true
    
    private var urlStringForChecking: String?
    private var emptyImage: UIImage?
    
    public convenience init(cornerRadius: CGFloat = 0, tapCallback: @escaping (() ->())) {
        self.init(cornerRadius: cornerRadius, emptyImage: nil)
        self.tapCallback = tapCallback
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        tapCallback?()
    }
    
    private var tapCallback: (() -> ())?
    
    public init(cornerRadius: CGFloat = 0, emptyImage: UIImage? = nil) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        self.emptyImage = emptyImage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Easily load an image from a URL string and cache it to reduce network overhead later.
     
     - parameter urlString: The url location of your image, usually on a remote server somewhere.
     - parameter completion: Optionally execute some task after the image download completes
     */
    
    open func loadImage(urlString: String, completion: (() -> ())? = nil) {
        image = nil
        
        self.urlStringForChecking = urlString
        
        let urlKey = urlString as NSString
        
        if let cachedItem = CachedImageView.imageCache.object(forKey: urlKey) {
            image = cachedItem.image
            completion?()
            return
        }
        
        guard let url = URL(string: urlString) else {
            if shouldUseEmptyImage {
                image = emptyImage
            }
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    let cacheItem = DiscardableImageCacheItem(image: image)
                    CachedImageView.imageCache.setObject(cacheItem, forKey: urlKey)
                    
                    if urlString == self?.urlStringForChecking {
                        self?.image = image
                        completion?()
                    }
                }
            }
            
        }).resume()
    }
}

struct CharacterCellModel {
    var name: String
    var imageUrl: String
}

class MarvelCharacterCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        return label
    }()
    
    let charImageView: CachedImageView = {
        let imageView = CachedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ironman")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        addSubview(charImageView)

        nameLabel.anchor(left: leftAnchor, top: topAnchor, edgesInsets: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 0))
        charImageView.anchor(top: nameLabel.bottomAnchor, width: 250, height: 250, edgesInsets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let cellId: String = "charactersCellId"
    
    var characters: [CharacterCellModel] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        collectionView.register(MarvelCharacterCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        
        MarvelService.shared.fetchData(withSuccess: { (model) in
            self.characters = model.data.results.map({ (char) -> CharacterCellModel in
                return CharacterCellModel(name: char.name, imageUrl: "\(char.thumbnail.path).\(char.thumbnail.extension)")
            })
        }) { (error) in
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 8 + 8 + 250 + 16 + 20
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MarvelCharacterCell
        cell.backgroundColor = .red
        cell.nameLabel.text = characters[indexPath.row].name
        cell.charImageView.loadImage(urlString: characters[indexPath.row].imageUrl)
        return cell
    }
}

