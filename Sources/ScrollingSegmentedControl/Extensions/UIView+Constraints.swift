import UIKit

extension UIView {
    func addConstraintsToFitIntoSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing]) {
        guard let parent = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = attributes.contains(.top)
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = attributes.contains(.bottom)
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = attributes.contains(.leading)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = attributes.contains(.trailing)
    }
}
