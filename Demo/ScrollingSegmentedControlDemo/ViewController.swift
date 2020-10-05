import UIKit
import ScrollingSegmentedControl

class ViewController: UIViewController {
    @IBOutlet weak var scrollingSegmentedControl: ScrollingSegmentedControl!
    
    @IBOutlet weak var selectedSegmentIndexLabel: UILabel!
    @IBOutlet weak var stepperValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedSegmentIndexLabel.text = "Index: \(scrollingSegmentedControl.selectedSegmentIndex)"
        stepperValueLabel.text = "Segments: \(scrollingSegmentedControl.numberOfSegments)"
    }
    
    
    
    @IBAction func segmentValueChanged(_ sender: ScrollingSegmentedControl) {
        selectedSegmentIndexLabel.text = "Index: \(sender.selectedSegmentIndex)"
    }
    
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let intArray = Array(0..<Int(sender.value))
        let stringArray = intArray.map({ String($0) })
        self.scrollingSegmentedControl.segmentTitles = stringArray
        
        stepperValueLabel.text = "Segments: \(Int(sender.value))"
    }
    
    @IBAction func updateDidTap(_ sender: Any) {
        ()
    }
}


