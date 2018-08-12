import UIKit

extension UIView {
    func addConstraintsToFitIntoSuperview(attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .leading, .trailing]) {
        guard let parent = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = attributes.contains(.top)
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = attributes.contains(.bottom)
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = attributes.contains(.leading)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = attributes.contains(.trailing)
    }
}
/*
extension UIButton {
    private func image(with color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(with: color), for: state)
    }
}
 */

extension UIColor {
    open class var systemBlue: UIColor {
        return UIView().tintColor
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
}
