import UIKit

internal class SegmentButton: UIButton {
    private var backgroundColors: [UIControl.State: UIColor] = [:]

    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.backgroundColors[self.state]
        }
    }

    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        self.backgroundColors[state] = color
    }
}
