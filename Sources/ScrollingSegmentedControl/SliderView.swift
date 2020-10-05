import UIKit

internal class SliderView: UIView {
    var sizeDelegate: SliderViewSizeDelegate?
    var longPressGestureRecognizer: UILongPressGestureRecognizer!

    override func layoutSubviews() {
        super.layoutSubviews()
        sizeDelegate?.sliderViewSizeDidChange(sliderView: self)
    }
}

internal protocol SliderViewSizeDelegate {
    func sliderViewSizeDidChange(sliderView: UIView)
}
