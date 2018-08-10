import UIKit

extension UIView {
    func addConstraintsToFitIntoSuperview() {
        guard let parent = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
    }
}
