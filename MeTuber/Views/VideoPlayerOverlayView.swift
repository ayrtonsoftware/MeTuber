import UIKit

class VideoPlayerOverlayView: UIView {
    // MARK: - UI Components

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var slider: UISlider!

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor,
        ]
        layer.locations = [0, 1]
        return layer
    }()

    // MARK: - Properties

    var descriptionText: String? {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        // setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // setupView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureLabel()
    }

    private func configureLabel() {
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 32 // Account for leading/trailing constraints
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
    }

    // MARK: - Public Methods

    func updateProgress(currentTime: Float, duration: Float) {
        print("Playback: current \(currentTime) duration \(duration)")
        if duration.isNaN {
            return
        }
        slider.isHidden = false
        slider.minimumValue = 0
        slider.maximumValue = duration
        slider.value = currentTime
    }

    func updatePlaybackState(isPlaying: Bool) {
        print("Is playing: \(isPlaying)")
    }

    func update(with video: Video) {
        descriptionText = video.description
    }

    func show() {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
}
