import UIKit

internal class SliderScrollView: UIScrollView {
    var scrollingSegmentedControl: ScrollingSegmentedControl?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superControl = scrollingSegmentedControl else {
            return super.point(inside: point, with: event)
        }
        return superControl.bounds.contains(self.convert(point, to: superControl))
    }
}
