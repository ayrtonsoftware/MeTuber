//
//  VideoCell.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

import DependencyInjection
import UIKit

class VideoCell: UICollectionViewCell {
    private(set) var item: Video?
    @IBOutlet var videoId: UILabel?
    @IBOutlet var thumbnailImageView: GIFAnimationView?
    static var NotFound: Data?
    
    func setItem(_ item: Video) {
        self.item = item
        videoId?.text = item.video.description
        
        // Reset the image view while loading
        //thumbnailImageView?.image = nil
        
        guard let dm: IDownloadManager = DIContainer.resolve() else {
            print("Failed to resolve DownloadManager")
            return
        }
        
        if let url = URL(string: item.previewURL) {
            print(item.previewURL)
            print("-------------------")
            dm.download(url: url) { result in
                switch result {
                case let .success(data):
                    // Create image from downloaded data
                    self.thumbnailImageView?.setGIFData(data)
                case let .failure(error):
                    print("Failed to download thumbnail: \(error.localizedDescription)")
                    if let notFound = Self.NotFound {
                        self.thumbnailImageView?.setGIFData(notFound)
                    } else {
                        if let notFound = Data.loadEmbeddedFile(filename: "404", ext: "gif") {
                            VideoCell.NotFound = notFound
                            self.thumbnailImageView?.setGIFData(notFound)
                        }
                    }
                }
            }
        }
    }
}
