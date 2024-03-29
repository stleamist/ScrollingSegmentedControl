import UIKit

extension ScrollingSegmentedControl {
    static public let noSegment: Int = -1
}

@IBDesignable public class ScrollingSegmentedControl: UIControl {
    
    
    // MARK: View Properties
    
    private var scrollView: SliderScrollView = SliderScrollView()
    private var scrollContentView: UIView = UIView()
    private var sliderView: SliderView = SliderView()
    private var sliderMaskView: UIView = UIView()

    private var backgroundStackView: UIStackView = UIStackView()
    private var foregroundStackView: UIStackView = UIStackView()

    private var foregroundStackContainerView: UIView = UIView()
    
    
    // MARK: Gesture Recognizers
    
    // TODO: gestureRecognizer를 각각의 클래스 인스턴스 내부에 할당해야 할지 결정하기
    private var backgroundSegmentsLongPressGestureRecognizer: UILongPressGestureRecognizer!
    private var sliderViewLongPressGestureRecognizer: UILongPressGestureRecognizer!
    
    private var scrollViewWidthAnchor: NSLayoutConstraint?
    
    
    // MARK: Stored Properties
    
    public var segmentTitles: [String] = ["First", "Second"] {
        didSet {
            validateSelectedSegmentIndex()
            updateScrollViewWidthAnchorMultiplier()
            updateSliderMaskViewFrame()
            setupSegmentButtons()
        }
    }
    
    private var backgroundSegments: [SegmentButton] = [] {
        didSet {
            backgroundStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
            backgroundSegments.forEach({ backgroundStackView.addArrangedSubview($0) })
        }
    }
    private var foregroundSegments: [SegmentButton] = [] {
        didSet {
            foregroundStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
            foregroundSegments.forEach({ foregroundStackView.addArrangedSubview($0) })
        }
    }
    
    public var selectedSegmentIndex: Int = ScrollingSegmentedControl.noSegment {
        didSet {
            validateSelectedSegmentIndex() // didSet 내에서의 프로퍼티 변경은 didSet을 재호출하지 않는다.
            
            if oldValue != selectedSegmentIndex {
                sendActions(for: .valueChanged)
            }
            if (oldValue == ScrollingSegmentedControl.noSegment || selectedSegmentIndex == ScrollingSegmentedControl.noSegment) {
                updateSliderViewHiddenState()
                updateScrollViewOffset(animated: false)
                return
            }
            
            updateScrollViewOffset(animated: true)
        }
    }
    
    public var highlightedSegmentIndex: Int? {
        didSet {
            if oldValue == nil, let newIndex = highlightedSegmentIndex { // began
                let newSegment = backgroundSegments[newIndex]
                
                setHighlightedState(of: newSegment, to: true, animationDuration: backgroundSegmentBeginHighlightingAnimationDuration)
            }
            else if let oldIndex = oldValue, let newIndex = highlightedSegmentIndex, oldIndex != newIndex { // changed
                let oldSegment = backgroundSegments[oldIndex]
                let newSegment = backgroundSegments[newIndex]
                
                setHighlightedState(of: oldSegment, to: false, animationDuration: backgroundSegmentChangeHighlightingAnimationDuration)
                setHighlightedState(of: newSegment, to: true, animationDuration: backgroundSegmentChangeHighlightingAnimationDuration)
            }
            else if let oldIndex = oldValue, highlightedSegmentIndex == nil { // ended
                let oldSegment = backgroundSegments[oldIndex]
                
                setHighlightedState(of: oldSegment, to: false, animationDuration: backgroundSegmentEndHighlightingAnimationDuration)
            }
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            self.backgroundColor = self.backgroundColors[self.state]
        }
    }
    
    
    // MARK: Computed Properties
    
    public var numberOfSegments: Int {
        return segmentTitles.count
    }
    
    private var scrollViewWidthMultiplier: CGFloat {
        guard numberOfSegments > 0 else {
            return 0
        }
        return (1 / CGFloat(numberOfSegments))
    }
    
    
    // MARK: Appearance Properties & Methods
    
    private var backgroundColors: [UIControl.State: UIColor] = [
        .normal: UIColor(rgb: 0xF1F2F2),
        .highlighted: UIColor(rgb: 0xD5D6D9)
    ]
    private var segmentBackgroundColors: [UIControl.State: UIColor] = [
        .normal: .clear,
        .highlighted: UIColor(rgb: 0xD9EBFF), // UIColor.systemBlue.withAlphaComponent(0.15)
        .selected: .systemBlue
    ]
    private var segmentTitleColors: [UIControl.State: UIColor] = [
        .normal: .black,
        .highlighted: .black,
        .selected: .white
    ]
    
    public func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        backgroundColors[state] = color
    }
    
    public func setSegmentColor(_ color: UIColor?, for state: UIControl.State) {
        segmentBackgroundColors[state] = color
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 8 {
        didSet {
            updateCornerRadius()
        }
    }
    
    
    // MARK: Duration Constants
    
    private let controlBeginHighlightingAnimationDuration: TimeInterval = 0.25
    private let controlEndHighlightingAnimationDuration: TimeInterval = 0.25
    
    private let backgroundSegmentBeginHighlightingAnimationDuration: TimeInterval = 0.1
    private let backgroundSegmentChangeHighlightingAnimationDuration: TimeInterval = 0.1
    private let backgroundSegmentEndHighlightingAnimationDuration: TimeInterval = 0.25
    
    private let sliderViewAppearAnimationDuration: TimeInterval = 0.25
    
    
    // MARK: Initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience public init(titles: [String]?) {
        self.init()
        self.segmentTitles = titles ?? []
    }
    
    
    // MARK: Private Setup Methods
    
    private func setup() {
        setupSubviews()
        setupStackViews()
        setupSegmentButtons()
        setupScrollView()
        setupSliderView()
        setupGestureRecognizers()
        
        setColors()
        updateCornerRadius()
        
        updateSliderViewHiddenState()
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
    
    private func setupStackViews() {
        for stackView in [backgroundStackView, foregroundStackView] {
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
        }
        
        for view in [backgroundStackView, foregroundStackContainerView] {
            view.isUserInteractionEnabled = false
        }
    }
    
    private func setupSegmentButtons() {
        // TODO: cornerRadius 할당이 중복되는 문제 해결하기
        
        foregroundSegments = segmentTitles.map({ title -> SegmentButton in
            let button = SegmentButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(self.segmentTitleColors[.selected], for: .normal)
            button.layer.cornerRadius = self.cornerRadius
            button.clipsToBounds = true
            return button
        })
        
        backgroundSegments = segmentTitles.map({ title -> SegmentButton in
            let button = SegmentButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(self.segmentTitleColors[.normal], for: .normal)
            button.setTitleColor(self.segmentTitleColors[.highlighted], for: .highlighted)
            button.setBackgroundColor(self.segmentBackgroundColors[.highlighted], for: .highlighted)
            button.layer.cornerRadius = self.cornerRadius
            button.clipsToBounds = true
            return button
        })
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        
        self.clipsToBounds = true
        scrollView.clipsToBounds = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.delegate = self
        scrollView.scrollingSegmentedControl = self
        sliderView.addGestureRecognizer(scrollView.panGestureRecognizer)
    }
    
    private func setupSliderView() {
        sliderView.sizeDelegate = self
        
        sliderMaskView.backgroundColor = .black
        foregroundStackContainerView.layer.mask = sliderMaskView.layer
    }
    
    private func setupGestureRecognizers() {
        self.backgroundSegmentsLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleBackgroundSegmentsLongPress(_:)))
        backgroundSegmentsLongPressGestureRecognizer.minimumPressDuration = 0
        backgroundSegmentsLongPressGestureRecognizer.delegate = self
        self.addGestureRecognizer(self.backgroundSegmentsLongPressGestureRecognizer)
        
        sliderView.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleSliderViewLongPress(_:)))
        sliderView.longPressGestureRecognizer.minimumPressDuration = 0
        sliderView.longPressGestureRecognizer.delegate = self
        sliderView.addGestureRecognizer(sliderView.longPressGestureRecognizer)
    }
    
    private func setColors() {
        self.backgroundColor = self.backgroundColors[.normal]
        sliderView.backgroundColor = self.segmentBackgroundColors[.selected]
        
        scrollView.backgroundColor = .clear
        scrollContentView.backgroundColor = .clear
        backgroundStackView.backgroundColor = .clear
        foregroundStackContainerView.backgroundColor = .clear
    }
    
    
    // MARK: Update Methods
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundStackView.layoutSubviews()
        updateScrollViewOffset(animated: false)
    }
    
    private func updateCornerRadius() {
        self.layer.cornerRadius = cornerRadius
        sliderView.layer.cornerRadius = cornerRadius
        sliderMaskView.layer.cornerRadius = cornerRadius
        backgroundSegments.forEach { $0.layer.cornerRadius = cornerRadius }
        foregroundSegments.forEach { $0.layer.cornerRadius = cornerRadius }
    }
    
    private func updateScrollViewOffset(animated: Bool) {
        guard let lastSegment = backgroundSegments.last, let selectedSegment = backgroundSegments[safe: self.selectedSegmentIndex] else {
            // numberOfSegments = 0 or selectedSegmentIndex = -1
            return
        }
        
        // scrollView.bounds.width * numberOfSegments가 항상 scrollView.contentSize.width와 일치하지 않기 때문에 이 방법이 정확하다.
        let scrollViewOffsetX = selectedSegment.convert(selectedSegment.bounds.origin, from: lastSegment).x
        scrollView.setContentOffset(CGPoint(x: scrollViewOffsetX, y: 0), animated: animated)
    }
    
    private func updateScrollViewWidthAnchorMultiplier() {
        // The isActive property automatically adds and removes the constraint from the correct view.
        self.scrollViewWidthAnchor?.isActive = false
        
        self.scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: self.scrollViewWidthMultiplier)
        self.scrollViewWidthAnchor?.isActive = true
    }
    
    private func updateSliderViewHiddenState() {
        if selectedSegmentIndex == ScrollingSegmentedControl.noSegment {
            self.scrollView.isHidden = true
            self.foregroundStackContainerView.isHidden = true
            
            self.scrollView.alpha = 0
            self.foregroundStackContainerView.alpha = 0
        }
        else {
            UIView.animate(withDuration: sliderViewAppearAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.scrollView.isHidden = false
                self.foregroundStackContainerView.isHidden = false
                
                self.scrollView.alpha = 1
                self.foregroundStackContainerView.alpha = 1
            })
        }
    }
    
    
    // MARK: Helper Methods
    
    func validateSelectedSegmentIndex() {
        guard (0..<numberOfSegments).contains(selectedSegmentIndex) || selectedSegmentIndex == ScrollingSegmentedControl.noSegment else {
            selectedSegmentIndex = ScrollingSegmentedControl.noSegment
            return
        }
    }
    
    private func setHighlightedState(of control: UIControl, to isHighlighted: Bool, animationDuration duration: TimeInterval = 0) {
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
        switch sender.state {
        case .began:
            setHighlightedState(of: self, to: true, animationDuration: controlBeginHighlightingAnimationDuration)
        
        case .ended, .cancelled:
            setHighlightedState(of: self, to: false, animationDuration: controlEndHighlightingAnimationDuration)
        
        default:
            ()
        }
    }
    
    @objc private func handleBackgroundSegmentsLongPress(_ sender: UILongPressGestureRecognizer) {
        let boundedLocationX = min(max(0, sender.location(in: foregroundStackView).x), foregroundStackView.bounds.width)
        
        let currentIndex = backgroundSegments.firstIndex { segment -> Bool in
            return (segment.frame.minX...segment.frame.maxX).contains(boundedLocationX)
        }
        
        switch sender.state {
        case .began:
            self.highlightedSegmentIndex = currentIndex
            
        case .changed:
            self.highlightedSegmentIndex = currentIndex
            
        case .ended, .cancelled:
            self.highlightedSegmentIndex = nil
            self.selectedSegmentIndex = currentIndex ?? ScrollingSegmentedControl.noSegment
            
        default:
            ()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let recognizers: Set = [gestureRecognizer, otherGestureRecognizer]
        if recognizers.contains(sliderView.longPressGestureRecognizer) && recognizers.contains(scrollView.panGestureRecognizer) {
            return true
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.backgroundSegmentsLongPressGestureRecognizer && otherGestureRecognizer == scrollView.panGestureRecognizer {
            return true
        }
        return false
    }
}

extension ScrollingSegmentedControl: UIScrollViewDelegate, SliderViewSizeDelegate {
    
    
    // MARK: ScrollView Delegate Methods
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            setSelectedSegmentIndexByScrollViewOffset()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedSegmentIndexByScrollViewOffset()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSliderMaskViewFrame()
    }
    
    
    // MARK: SliderViewSizeDelegate Methods
    
    internal func sliderViewSizeDidChange(sliderView: UIView) {
        updateSliderMaskViewFrame()
    }
    
    
    // MARK: Update Methods
    
    private func setSelectedSegmentIndexByScrollViewOffset() {
        let complementIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let index = (numberOfSegments - 1) - complementIndex
        self.selectedSegmentIndex = index
    }
    
    private func updateSliderMaskViewFrame() {
        sliderMaskView.frame = sliderView.convert(sliderView.bounds, to: foregroundStackContainerView)
    }
}
