import UIKit

@IBDesignable class ScrollingSegmentedControl: UIControl {
    let controlBeginHighlightingAnimationDuration: TimeInterval = 0.25
    let controlEndHighlightingAnimationDuration: TimeInterval = 0.25
    
    let backgroundSegmentBeginHighlightingAnimationDuration: TimeInterval = 0.10
    let backgroundSegmentChangeHighlightingAnimationDuration: TimeInterval = 0.10
    let backgroundSegmentEndHighlightingAnimationDuration: TimeInterval = 0.25
    
    
    // MARK: View Properties
    
    var scrollView: SliderScrollView = SliderScrollView()
    var scrollContentView: UIView = ContentView()
    var sliderView: SliderView = SliderView()
    var sliderMaskView: UIView = SliderMaskView()
    
    var foregroundStackContainerView: UIView = StackContainerView()
    
    var backgroundStackView: UIStackView = UIStackView()
    var foregroundStackView: UIStackView = UIStackView()
    
    private var scrollViewWidthAnchor: NSLayoutConstraint?
    
    private var sliderViewLongPressGestureRecognizer: UILongPressGestureRecognizer!
    private var backgroundSegmentsLongPressGestureRecognizer: UILongPressGestureRecognizer!
    
    
    // MARK: Stored Properties
    
    var selectedSegmentIndex: Int = 0 {
        didSet {
            if oldValue != selectedSegmentIndex {
                sendActions(for: .valueChanged)
            }
            updateScrollViewOffset(animated: true)
        }
    }
    
    var highlightedSegmentIndex: Int? {
        didSet {
            if oldValue == nil, let newIndex = highlightedSegmentIndex { // began
                let newSegment = backgroundSegmentButtons[newIndex]
                
                setHighlightedState(of: newSegment, to: true, animationDuration: self.backgroundSegmentBeginHighlightingAnimationDuration)
            }
            else if let oldIndex = oldValue, let newIndex = highlightedSegmentIndex, oldIndex != newIndex { // changed
                let oldSegment = backgroundSegmentButtons[oldIndex]
                let newSegment = backgroundSegmentButtons[newIndex]
                
                setHighlightedState(of: oldSegment, to: false, animationDuration: backgroundSegmentChangeHighlightingAnimationDuration)
                setHighlightedState(of: newSegment, to: true, animationDuration: backgroundSegmentChangeHighlightingAnimationDuration)
            }
            else if let oldIndex = oldValue, highlightedSegmentIndex == nil { // ended
                let oldSegment = backgroundSegmentButtons[oldIndex]
                
                setHighlightedState(of: oldSegment, to: false, animationDuration: backgroundSegmentEndHighlightingAnimationDuration)
            }
        }
    }
    
    var segmentTitles: [String] = ["First", "Second", "Third", "Fourth"] {
        didSet {
            updateScrollViewWidthAnchorMultiplier()
            updateSliderMaskViewFrame()
            setupSegmentButtons()
        }
    }
    
    var segmentImages: [UIImage] = [] {
        didSet {
            
        }
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state.rawValue] = color
    }
    
    func setSegmentColor(_ color: UIColor?, for state: UIControl.State) {
        segmentColors[state.rawValue] = color
    }
    
    private var backgroundColors: [UIControl.State.RawValue: UIColor] = [
        UIControl.State.normal.rawValue: UIColor(rgb: 0xF1F2F2),
        UIControl.State.highlighted.rawValue: UIColor(rgb: 0xD5D6D9)
    ]
    
    private var segmentColors: [UIControl.State.RawValue: UIColor] = [
        UIControl.State.normal.rawValue: .clear,
        UIControl.State.highlighted.rawValue: UIColor(rgb: 0xD9EBFF), // UIColor.systemBlue.withAlphaComponent(0.15)
        UIControl.State.selected.rawValue: .systemBlue
    ]
    
    var segmentCornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = segmentCornerRadius
            sliderView.layer.cornerRadius = segmentCornerRadius
            sliderMaskView.layer.cornerRadius = segmentCornerRadius
            backgroundSegmentButtons.forEach { $0.layer.cornerRadius = segmentCornerRadius }
            foregroundSegmentButtons.forEach { $0.layer.cornerRadius = segmentCornerRadius }
        }
    }
    
    private var backgroundSegmentButtons: [SegmentButton] = []
    private var foregroundSegmentButtons: [SegmentButton] = []
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.backgroundColors[self.state.rawValue]
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
    
    convenience init(titles: [String]?, images: [UIImage]?) {
        self.init()
        self.segmentTitles = titles ?? []
        self.segmentImages = images ?? []
    }
    
    
    // MARK: Private Setup Methods
    
    private func setup() {
        setupSubviews()
        
        setupScrollView()
        setupStackViews()
        setupSliderView()
        
        setupAppearance()
        
        setupSegmentButtons()
    }
    
    private func setupSubviews() {
        
        // Add Subviews
        
        self.addSubview(backgroundStackView)
        
        self.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(sliderView)
        
        self.addSubview(foregroundStackContainerView)
        foregroundStackContainerView.addSubview(foregroundStackView)
        foregroundStackContainerView.addSubview(sliderMaskView)
        
        
        // Add Constraints
        
        backgroundStackView.addConstraintsToFitIntoSuperview()
        
        scrollView.addConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        updateScrollViewWidthAnchorMultiplier()
        
        scrollContentView.addConstraintsToFitIntoSuperview()
        scrollContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        scrollContentView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        sliderView.addConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        sliderView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        foregroundStackContainerView.addConstraintsToFitIntoSuperview()
        foregroundStackView.addConstraintsToFitIntoSuperview()
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        // panGestureRecognizer를 self에 추가하면 segmentView 외부에서도 스크롤할 수 있다.
        // TODO: var allowsScrollOnBackground: Bool 추가하기
        // TODO: Gesture Recognizer 관련 코드는 다른 메소드로 분리하기
        
        self.sliderViewLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleSliderViewLongPress(_:)))
        sliderViewLongPressGestureRecognizer.minimumPressDuration = 0
        sliderViewLongPressGestureRecognizer.delegate = self
        sliderView.addGestureRecognizer(sliderViewLongPressGestureRecognizer)
        
        self.backgroundSegmentsLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleBackgroundSegmentsLongPress(_:)))
        backgroundSegmentsLongPressGestureRecognizer.minimumPressDuration = 0
        backgroundSegmentsLongPressGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.backgroundSegmentsLongPressGestureRecognizer)
        
        sliderView.addGestureRecognizer(scrollView.panGestureRecognizer)
        
        scrollView.scrollingSegmentedControl = self
        
        self.clipsToBounds = true
        scrollView.clipsToBounds = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func setupStackViews() {
        for stackView in [backgroundStackView, foregroundStackView] {
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
        }
        
        for containerView in [backgroundStackView, foregroundStackContainerView] {
            containerView.isUserInteractionEnabled = false
        }
    }
    
    private func setupSliderView() {
        sliderView.sizeDelegate = self
        
        sliderMaskView.backgroundColor = .black
        foregroundStackContainerView.layer.mask = sliderMaskView.layer
    }
    
    private func setupSegmentButtons() {
        // TODO: backgroundButtons의 textLabel에서 복제해 오기
        // TODO: Don't Repeat Yourself
        for button in foregroundSegmentButtons {
            foregroundStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        foregroundSegmentButtons.removeAll()
        
        for title in segmentTitles {
            let button = SegmentButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = self.segmentCornerRadius
            button.clipsToBounds = true
            foregroundStackView.addArrangedSubview(button)
            foregroundSegmentButtons.append(button)
        }
        
        
        for button in backgroundSegmentButtons {
            backgroundStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        backgroundSegmentButtons.removeAll()
        
        for title in segmentTitles {
            let button = SegmentButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            //button.setBackgroundColor(self.segmentDefaultColor, for: .normal)
            button.setBackgroundColor(self.segmentColors[UIControl.State.highlighted.rawValue] ?? .clear, for: .highlighted)
            button.layer.cornerRadius = self.segmentCornerRadius
            button.clipsToBounds = true
            backgroundStackView.addArrangedSubview(button)
            backgroundSegmentButtons.append(button)
        }
    }
    
    private func setupAppearance() {
        self.backgroundColor = self.backgroundColors[UIControl.State.normal.rawValue]
        scrollView.backgroundColor = .clear
        scrollContentView.backgroundColor = .clear
        foregroundStackContainerView.backgroundColor = .clear
        sliderView.backgroundColor = self.segmentColors[UIControl.State.selected.rawValue]
        
        self.segmentCornerRadius = 22
    }
    
    
    // MARK: Action Methods
    
    func updateScrollViewOffset(animated: Bool) {
        // FIXME: selectedSegmentIndex > numberOfSegments - 1 일 때 오류 발생
        let selectedSegment = backgroundSegmentButtons[selectedSegmentIndex]
        guard let lastSegment = backgroundSegmentButtons.last else {
            return
        }
        
        // scrollView.bounds.width * numberOfSegments가 항상 scrollView.contentSize.width와 일치하지 않기 때문에 이 방법이 정확하다.
        let scrollViewOffsetX = selectedSegment.convert(selectedSegment.bounds.origin, from: lastSegment).x
        print(#function, scrollView.bounds.width, selectedSegment.frame, lastSegment.frame, scrollViewOffsetX)
        self.scrollView.setContentOffset(CGPoint(x: scrollViewOffsetX, y: 0), animated: animated)
    }
    
    // FIXME: 더블탭 시 슬라이더가 멈추는 현상 있음
    // FIXME: 초기 로딩 시 애니메이션 끄기
    
    
    // MARK: Update Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundStackView.layoutSubviews()
        self.updateScrollViewOffset(animated: false)
    }
    
    private func updateScrollViewWidthAnchorMultiplier() {
        // The isActive property automatically adds and removes the constraint from the correct view.
        self.scrollViewWidthAnchor?.isActive = false
        
        self.scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.scrollViewWidthMultiplier)
        self.scrollViewWidthAnchor?.isActive = true
    }
    
    func setHighlightedState(of control: UIControl, to isHighlighted: Bool, animationDuration duration: TimeInterval = 0) {
        let handler = {
            control.isHighlighted = isHighlighted
        }
        
        if duration > 0 {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: handler)
        } else {
            handler()
        }
    }
}

extension ScrollingSegmentedControl: UIGestureRecognizerDelegate {
    @objc private func handleSliderViewLongPress(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            setHighlightedState(of: self, to: true, animationDuration: controlBeginHighlightingAnimationDuration)
        }
        
        if(sender.state == .ended || sender.state == .cancelled) {
            setHighlightedState(of: self, to: false, animationDuration: controlEndHighlightingAnimationDuration)
        }
    }
    
    @objc private func handleBackgroundSegmentsLongPress(_ sender: UILongPressGestureRecognizer) {
        let boundedLocationX = min(max(0, sender.location(in: foregroundStackView).x), foregroundStackView.bounds.width)
        
        // TODO: 옵셔널 처리
        let currentIndex = backgroundSegmentButtons.firstIndex { segment -> Bool in
            return (segment.frame.minX...segment.frame.maxX).contains(boundedLocationX)
        }
        
        switch sender.state {
        case .began:
            self.highlightedSegmentIndex = currentIndex
            
        case .changed:
            self.highlightedSegmentIndex = currentIndex
            
        case .ended, .cancelled:
            self.highlightedSegmentIndex = nil
            
            // TODO: 옵셔널 처리
            self.selectedSegmentIndex = currentIndex ?? self.selectedSegmentIndex
            
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let recognizers: Set = [gestureRecognizer, otherGestureRecognizer]
        if recognizers.contains(self.sliderViewLongPressGestureRecognizer) && recognizers.contains(scrollView.panGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print(type(of: gestureRecognizer), type(of: otherGestureRecognizer))
        if gestureRecognizer == self.backgroundSegmentsLongPressGestureRecognizer && otherGestureRecognizer == scrollView.panGestureRecognizer {
            return true
        }
        return false
    }
}

extension ScrollingSegmentedControl: UIScrollViewDelegate, SliderViewSizeDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSliderMaskViewFrame()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            setSelectedSegmentIndexByScrollViewOffset()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedSegmentIndexByScrollViewOffset()
    }
    
    func setSelectedSegmentIndexByScrollViewOffset() {
        let complementIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let index = (numberOfSegments - 1) - complementIndex
        self.selectedSegmentIndex = index
        
        print(#function, scrollView.contentOffset.x, scrollView.bounds.width, scrollView.contentOffset.x / scrollView.bounds.width, index)
    }
    
    func sliderViewSizeDidChange(sliderView: UIView) {
        updateSliderMaskViewFrame()
    }
    
    private func updateSliderMaskViewFrame() {
        sliderMaskView.frame = sliderView.convert(sliderView.bounds, to: foregroundStackContainerView)
    }
}

class SliderScrollView: UIScrollView {
    var scrollingSegmentedControl: ScrollingSegmentedControl?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superControl = scrollingSegmentedControl else {
            return super.point(inside: point, with: event)
        }
        return superControl.bounds.contains(self.convert(point, to: superControl))
    }
}

class SliderView: UIView {
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    var sizeDelegate: SliderViewSizeDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sizeDelegate?.sliderViewSizeDidChange(sliderView: self)
    }
}

protocol SliderViewSizeDelegate {
    func sliderViewSizeDidChange(sliderView: UIView)
}

class SegmentButton: UIButton {
    private var backgroundColors: [UIControl.State.RawValue: UIColor] = [:]
    
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.backgroundColors[self.state.rawValue]
        }
    }
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        self.backgroundColors[state.rawValue] = color
    }
}


// MARK: Custom Classes for Debugging

class StackContainerView: UIView {}
class ContentView: UIView {}
class SliderMaskView: UIView {}
