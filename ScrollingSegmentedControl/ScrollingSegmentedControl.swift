import UIKit

@IBDesignable class ScrollingSegmentedControl: UIControl {
    
    // MARK: View Properties
    
    var scrollView: SegmentScrollView = SegmentScrollView()
    var scrollContentView: UIView = UIView()
    var segmentView: UIView = UIView()
    
    private var scrollViewWidthAnchor: NSLayoutConstraint?
    
    
    // MARK: Stored Properties
    
    var segmentTitles: [String] = ["First", "Second", "Third", "Fourth"] {
        didSet {
            updateScrollViewWidthAnchorMultiplier()
        }
    }
    
    
    // MARK: Computed Properties
    
    var numberOfSegments: Int {
        return segmentTitles.count
    }
    
    private var scrollViewWidthMultiplier: CGFloat {
        guard numberOfSegments > 0 else {
            return 0
        }
        return (1 / CGFloat(numberOfSegments))
    }
    
    
    // MARK: Debugging Properties
    
    var isDebugModeEnabled: Bool = false
    
    
    // MARK: Initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: Private Setup Methods
    
    private func setup() {
        setupSubviews()
        setupControl()
        setupAppearance()
    }
    
    private func setupSubviews() {
        self.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(segmentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.scrollViewWidthMultiplier)
        scrollViewWidthAnchor?.isActive = true
        
        scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        scrollContentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        segmentView.topAnchor.constraint(equalTo: scrollContentView.topAnchor).isActive = true
        segmentView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor).isActive = true
        segmentView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
        segmentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func setupControl() {
        scrollView.isPagingEnabled = true
        
        // panGestureRecognizer를 self에 추가하면 segmentView 외부에서도 스크롤할 수 있다.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerDidTap(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        segmentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        scrollView.scrollingSegmentedControl = self
        
        self.clipsToBounds = true
        scrollView.clipsToBounds = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func setupAppearance() {
        if isDebugModeEnabled {
            self.backgroundColor = .cyan
            scrollView.backgroundColor = .magenta
            scrollContentView.backgroundColor = .yellow
            segmentView.backgroundColor = .blue
        } else {
            self.backgroundColor = .lightGray
            scrollView.backgroundColor = .clear
            scrollContentView.backgroundColor = .clear
            segmentView.backgroundColor = segmentView.tintColor
            
            self.layer.cornerRadius = 12
            segmentView.layer.cornerRadius = 12
        }
    }
    
    
    // MARK: Private Observer Methods
    
    @objc private func tapGestureRecognizerDidTap(_ sender: UITapGestureRecognizer) {
        let tapLocationX: CGFloat = sender.location(in: self).x
        let scrollViewWidth: CGFloat = self.scrollView.bounds.width
        
        let index: Int = Int(tapLocationX / scrollViewWidth)
        let lastIndex: Int = (numberOfSegments - 1)
        let complementIndex: Int = (lastIndex - index)
        
        let scrollViewOffsetX: CGFloat = scrollViewWidth * CGFloat(complementIndex)
        
        self.scrollView.setContentOffset(CGPoint(x: scrollViewOffsetX, y: 0), animated: true)
    }
    
    private func updateScrollViewWidthAnchorMultiplier() {
        // The isActive property automatically adds and removes the constraint from the correct view.
        self.scrollViewWidthAnchor?.isActive = false
        
        self.scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.scrollViewWidthMultiplier)
        self.scrollViewWidthAnchor?.isActive = true
    }
}

class SegmentScrollView: UIScrollView {
    var scrollingSegmentedControl: ScrollingSegmentedControl?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superControl = scrollingSegmentedControl else {
            return super.point(inside: point, with: event)
        }
        return superControl.bounds.contains(self.convert(point, to: superControl))
    }
}
