import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var backgroundView: HitTestView!
    @IBOutlet weak var scrollView: HitTestScrollView!
    @IBOutlet weak var contentView: HitTestView!
    @IBOutlet weak var segmentView: HitTestView!
    
    @IBAction func tapGestureRecognizerDidTap(_ sender: UITapGestureRecognizer) {
        print(#function)
        
        let location = sender.location(in: self.backgroundView)
        let index = Int(location.x) / 125
        let lastIndex = 3 - 1
        
        let offset = 125 * (lastIndex - index)
        print(location, index, offset)
        
        self.scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        // let offset =
        /*
         0: 125 * 2
         1: 125 * 1
         2: 125 * 0
         
         0: 93 * 3
         1: 93 * 2
         2: 93 * 1
         3: 93 * 0
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Functional
        segmentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        scrollView.clipsToBounds = false
        backgroundView.clipsToBounds = true
        
        
        // Design
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        segmentView.layer.cornerRadius = 12
        backgroundView.layer.cornerRadius = 12
        
        
        // Debugging
        (self.view as! HitTestView).name = "view"
        backgroundView.name = "backgroundView"
        scrollView.name = "scrollView"
        contentView.name = "contentView"
        segmentView.name = "segmentView"
    }
}

protocol Nameable {
    var name: String { get set }
}

class HitTestView: UIView, Nameable {
    var name: String = ""
    /*
     override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
         let superHitTestView = super.hitTest(point, with: event)
         var nameOfHitTestView = ""
         if let hitTestView = superHitTestView as? NamedView {
         nameOfHitTestView = hitTestView.name
         }
         print(#function, nameOfHitTestView)
         return superHitTestView
     }
    */
}

class HitTestScrollView: UIScrollView, Nameable {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return superview!.bounds.contains(self.convert(point, to: superview))
    }
    
    var name: String = ""
    /*
     override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
     let superHitTestView = super.hitTest(point, with: event)
     var nameOfHitTestView = ""
     if let hitTestView = superHitTestView as? NamedView {
     nameOfHitTestView = hitTestView.name
     }
     print(#function, nameOfHitTestView)
     return superHitTestView
     }
     */
}
