import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scrollingSegmentedControl: ScrollingSegmentedControl!
    
    @IBOutlet weak var selectedSegmentIndexLabel: UILabel!
    @IBOutlet weak var stepperValueLabel: UILabel!
    
    
    
    @IBAction func segmentValueChanged(_ sender: ScrollingSegmentedControl) {
        selectedSegmentIndexLabel.text = String(sender.selectedSegmentIndex!)
    }
    @IBAction func updateDidTap(_ sender: Any) {
        self.scrollingSegmentedControl.updateScrollViewOffset(animated: false)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let intArray = Array(0...Int(sender.value))
        let stringArray = intArray.map({ String($0) })
        self.scrollingSegmentedControl.segmentTitles = stringArray
        stepperValueLabel.text = String(Int(sender.value))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
