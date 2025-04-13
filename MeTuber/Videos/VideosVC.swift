//
//  VideosVC.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//

import AVKit
import DependencyInjection
import UIKit

class VideosVC: UIViewController {
    @IBOutlet var videosCV: UICollectionView!
    //private var items: [PlayerVideo] = []
    private var vm: IVideoManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        videosCV.dataSource = self
        videosCV.delegate = self
        vm = DIContainer.resolve()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGrid()
    }

    private func setupGrid() {
        // Configure the Video Cell
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        videosCV.register(nib, forCellWithReuseIdentifier: "VideoCell")

        // Configure layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 4
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        // Calculate item size for exactly 3 rows
        let availableWidth = videosCV.bounds.width
        let availableHeight = videosCV.bounds.height
        // Account for content insets
        let contentInset = videosCV.contentInset
        let adjustedHeight = availableHeight - contentInset.top - contentInset.bottom
        // Account for 2 spacings between 3 items
        let totalSpacing = spacing * 2
        let itemHeight = floor((adjustedHeight - totalSpacing) / 3.0)
        let itemWidth = availableWidth

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        videosCV.collectionViewLayout = layout
    }
}

extension VideosVC: UICollectionViewDelegate {
    func collectionView(_: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    {
        if let ws = SceneDelegate.getWindowService(view: self.view),
           let vc: PlayerVC = ws.push(storyboard: "Player", name: "Player") as? PlayerVC {
            vc.setVideo(index: indexPath.row)
        }
    }
}

extension VideosVC: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return vm?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let vm = self.vm else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell",
                                                      for: indexPath) as! VideoCell
        if let video = vm.getVideo(index: indexPath.row) {
            cell.setItem(video)
        }
        return cell
    }
}
