import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scrollingSegmentedControl: ScrollingSegmentedControl!
    
    @IBOutlet weak var stepperValueLabel: UILabel!
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        self.scrollingSegmentedControl.segmentTitles = Array(repeating: "_", count: Int(sender.value))
        stepperValueLabel.text = String(Int(sender.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
