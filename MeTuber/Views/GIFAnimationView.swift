//
//  GIFAnimationView.swift
//  MeTube
//
//  Created by Michael Bergamo on 4/11/25.
//

import ImageIO
import UIKit
import UniformTypeIdentifiers

class GIFAnimationView: UIImageView {
    private var currentSource: CGImageSource?
    private var currentFrameCount: Int = 0
    private var currentFrameIndex: Int = 0
    private var displayLink: CADisplayLink?
    private var frameDurations: [TimeInterval] = []
    private var totalDuration: TimeInterval = 0
    private var lastFrameTime: TimeInterval = 0
    private var isGIFAnimating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentMode = .scaleAspectFit
        backgroundColor = .clear
    }

    deinit {
        stopAnimating()
        currentSource = nil
    }

    func setGIFData(_ data: Data) {
        // Clean up previous animation
        stopAnimating()
        currentSource = nil
        frameDurations.removeAll()
        currentFrameCount = 0
        currentFrameIndex = 0
        totalDuration = 0
        lastFrameTime = 0

        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source),
              type == UTType.gif.identifier as CFString
        else {
            print("Failed to load GIF data.")
            return
        }

        currentSource = source
        currentFrameCount = CGImageSourceGetCount(source)

        // Pre-calculate frame durations
        for i in 0 ..< currentFrameCount {
            let duration = getFrameDuration(from: source, at: i)
            frameDurations.append(duration)
            totalDuration += duration
        }

        // Start animation
        startAnimating()
    }

    override func startAnimating() {
        guard currentFrameCount > 0, !isGIFAnimating else { return }

        isGIFAnimating = true
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
        currentFrameIndex = 0
        lastFrameTime = CACurrentMediaTime()
        displayNextFrame()
    }

    override func stopAnimating() {
        isGIFAnimating = false
        displayLink?.invalidate()
        displayLink = nil
        currentFrameIndex = 0
        lastFrameTime = 0
    }

    @objc private func updateFrame() {
        guard displayLink != nil, isGIFAnimating else {
            return
        }

        let currentTime = CACurrentMediaTime()
        lastFrameTime = currentTime

        // Calculate the current position in the animation cycle
        let cycleTime = currentTime.truncatingRemainder(dividingBy: totalDuration)

        // Find the current frame based on accumulated durations
        var accumulatedTime: TimeInterval = 0
        for (index, duration) in frameDurations.enumerated() {
            accumulatedTime += duration
            if cycleTime < accumulatedTime {
                if index != currentFrameIndex {
                    currentFrameIndex = index
                    displayNextFrame()
                }
                break
            }
        }
    }

    private func displayNextFrame() {
        guard let source = currentSource,
              let cgImage = CGImageSourceCreateImageAtIndex(source, currentFrameIndex, nil)
        else {
            return
        }

        // Use autoreleasepool to ensure memory is released promptly
        autoreleasepool {
            image = UIImage(cgImage: cgImage)
        }
    }

    private func getFrameDuration(from source: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval ??
              gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval
        else {
            return 0.1 // Default frame duration
        }
        return max(0.02, delayTime) // Ensure minimum frame duration
    }
}
