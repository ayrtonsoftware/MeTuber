//
//  PlayerVC.swift
//  MeTuber
//
//  Created by Michael Bergamo on 4/12/25.
//

import AVFoundation
import AVKit
import DependencyInjection
import Foundation
import UIKit

class PlayerVC: AVPlayerViewController {
    private(set) var videoIndex: Int = 0
    private var vm: IVideoManager?
    private var overlayView: VideoPlayerOverlayView?

    // Player status tracking
    private var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerStatusObserver: NSKeyValueObservation?
    private var playerRateObserver: NSKeyValueObservation?

    public func setVideo(index: Int) {
        videoIndex = index
    }

    private func createPlayerItem(for video: Video) -> AVPlayerItem? {
        guard let url = URL(string: video.video) else { return nil }
        let playerItem = AVPlayerItem(url: url)
        playerItem.preferredForwardBufferDuration = 30 // Pre-buffer 30 seconds
        return playerItem
    }

    private func preloadNextVideos() {
        // Preload up to 3 videos ahead
        for offset in 1 ... 3 {
            let nextIndex = videoIndex + offset
            if var video = vm?.getVideo(index: nextIndex) {
                // Create AVPlayerItem if it doesn't exist and hasn't been preloaded
                if video.item == nil && !video.isPreloaded {
                    video.item = createPlayerItem(for: video)
                    video.isPreloaded = true
                }
            }
        }
    }

    private func playVideo(video: Video?) {
        guard let video = video else {
            return
        }
        // Create a mutable copy of the video
        var mutableVideo = video
        if mutableVideo.item == nil {
            mutableVideo.item = createPlayerItem(for: mutableVideo)
            mutableVideo.isPreloaded = true
        }

        if let vitem = mutableVideo.item {
            if let oldPlayer = player {
                oldPlayer.pause()
                removeObservers()
            }
            player = AVPlayer(playerItem: vitem)
            setupPlayerObservers()
            player?.play()
            overlayView?.descriptionText = mutableVideo.description
            overlayView?.updatePlaybackState(isPlaying: true)
        }
    }

    private func playVideo(index: Int) {
        if let video = vm?.getVideo(index: index) {
            videoIndex = index
            playVideo(video: video)
            // Preload next videos after setting up the current video
            preloadNextVideos()
        }
    }

    private func setupOverlayView() {
        if overlayView != nil {
            return
        }
        let nib = UINib(nibName: "VideoPlayerOverlay", bundle: nil)
        overlayView = nib.instantiate(withOwner: nil, options: nil).first as? VideoPlayerOverlayView
        overlayView?.backgroundColor = .clear
        guard let overlayView = overlayView else {
            print("Failed to load VideoPlayerOverlay from nib")
            return
        }

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView?.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: contentOverlayView!.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentOverlayView!.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentOverlayView!.bottomAnchor),
            overlayView.heightAnchor.constraint(equalTo: contentOverlayView!.heightAnchor, multiplier: 0.4),
        ])
    }

    private func setupPlayerObservers() {
        guard let player = player else { return }

        // Observe player status
        playerStatusObserver = player.observe(\.status) { [weak self] player, _ in
            switch player.status {
            case .readyToPlay:
                print("Player is ready to play")
                self?.overlayView?.updatePlaybackState(isPlaying: true)
            case .failed:
                print("Player failed with error: \(player.error?.localizedDescription ?? "unknown error")")
                self?.overlayView?.updatePlaybackState(isPlaying: false)
            case .unknown:
                print("Player status unknown")
            @unknown default:
                break
            }
        }

        // Observe player rate (play/pause)
        playerRateObserver = player.observe(\.rate) { [weak self] player, _ in
            self?.overlayView?.updatePlaybackState(isPlaying: player.rate > 0)
        }

        // Observe player item status
        playerItemStatusObserver = player.currentItem?.observe(\.status) { [weak self] item, _ in
            switch item.status {
            case .readyToPlay:
                print("Player item is ready to play")
            case .failed:
                print("Player item failed with error: \(item.error?.localizedDescription ?? "unknown error")")
            case .unknown:
                print("Player item status unknown")
            @unknown default:
                break
            }
        }

        // Add periodic time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let item = player.currentItem
            else {
                return
            }
            let currentTime = Float(time.seconds)
            let duration = Float(item.duration.seconds)
            self.overlayView?.updateProgress(currentTime: currentTime, duration: duration)
        }
    }

    private func removeObservers() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        playerStatusObserver?.invalidate()
        playerItemStatusObserver?.invalidate()
        playerRateObserver?.invalidate()
    }

    private func setupGestureRecognizers() {
        // Swipe up gesture
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUpGesture.direction = .up
        view.addGestureRecognizer(swipeUpGesture)

        // Swipe down gesture
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    @objc private func handleSwipeDown() {
        playVideo(index: videoIndex - 1)
    }

    @objc private func handleSwipeUp() {
        playVideo(index: videoIndex + 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupOverlayView()
        setupGestureRecognizers()
        vm = DIContainer.resolve()
        playVideo(index: videoIndex)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        player?.pause()
    }
}
