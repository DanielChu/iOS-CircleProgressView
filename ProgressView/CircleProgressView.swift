//
//  CircleProgressView.swift
//
//
//  Created by Eric Rolf on 8/11/14.
//  Copyright (c) 2014 Eric Rolf, Cardinal Solutions Group. All rights reserved.
//

import UIKit

@objc @IBDesignable public class CircleProgressView: UIView {
    
    private struct Constants {
        let circleDegress = 360.0
        let minimumValue = 0.000001
        let maximumValue = 0.999999
        let ninetyDegrees = 90.0
        let twoSeventyDegrees = 270.0
        var contentView:UIView = UIView()
    }
    //private var displayPercentageInCenter = false
    
    private let constants = Constants()
    private var internalProgress:Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var destinationProgress: Double = 0.0
    
    private var textLabel: UILabel? = nil
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let l = self.textLabel {
            var s = self.bounds.size.width
            if s > self.bounds.size.height {
                s = self.bounds.size.height
            }
            l.frame = self.bounds
            l.font = UIFont(name: "HelveticaNeue-Thin", size:0.37 * s)
        }
    }
    
    func setDisplayProgressInCenter(enabled: Bool) {
        if enabled {
            if self.textLabel == nil {
                let l = UILabel(frame: self.bounds)
                l.textAlignment = NSTextAlignment.Center
                l.textColor = self.centerTextColor
                var s = self.bounds.size.width
                if s > self.bounds.size.height {
                    s = self.bounds.size.height
                }
                let f = UIFont(name: "HelveticaNeue-Thin", size:0.37 * s)
                l.font = f
                self.textLabel = l
                //self.displayPercentageInCenter = true
                // add constraints
                
                //constraints = [NSLayoutConstraint]()
                self.addSubview(l)
            }
        } else {
            if let l = self.textLabel {
                l.removeFromSuperview()
                self.textLabel = nil
            }
            //self.displayPercentageInCenter = false
        }
    }
    
    @IBInspectable public var displayValueInCenter: Bool = false {
        didSet {
            self.setDisplayProgressInCenter(displayValueInCenter)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var centerValueAsPercentage: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var progress: Double = 0.000001 {
        didSet {
            internalProgress = progress
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var clockwise: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var trackWidth: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var centerTextColor: UIColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    
    @IBInspectable public var trackBackgroundColor: UIColor = UIColor.grayColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var trackFillColor: UIColor = UIColor.blueColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var secondTrackFillColor: UIColor = UIColor.redColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var trackBorderColor:UIColor = UIColor.clearColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var trackBorderWidth: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var centerFillColor: UIColor = UIColor.whiteColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var centerImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var contentView: UIView {
        return self.constants.contentView
    }
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
        self.addSubview(contentView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
        self.addSubview(contentView)
    }
    
    func internalInit() {
        displayLink = CADisplayLink(target: self, selector: Selector("displayLinkTick"))
    }
    
    override public func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        let innerRect = CGRectInset(rect, trackBorderWidth, trackBorderWidth)
        
        internalProgress = (internalProgress/1.0) == 0.0 ? constants.minimumValue : progress
        internalProgress = (internalProgress/1.0) == 1.0 ? constants.maximumValue : internalProgress
        internalProgress = clockwise ?
            (-constants.twoSeventyDegrees + ((1.0 - internalProgress) * constants.circleDegress)) :
            (constants.ninetyDegrees - ((1.0 - internalProgress) * constants.circleDegress))
        
        let context = UIGraphicsGetCurrentContext()
        
        // background Drawing
        trackBackgroundColor.setFill()
        let circlePath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect)))
        circlePath.fill();
        
        if trackBorderWidth > 0 {
            circlePath.lineWidth = trackBorderWidth
            trackBorderColor.setStroke()
            circlePath.stroke()
        }
        
        // progress Drawing
        let progressPath = UIBezierPath()
        let progressRect: CGRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
        let center = CGPointMake(progressRect.midX, progressRect.midY)
        let radius = progressRect.width / 2.0
        let startAngle:CGFloat = clockwise ? CGFloat(-internalProgress * M_PI / 180.0) : CGFloat(constants.twoSeventyDegrees * M_PI / 180)
        let endAngle:CGFloat = clockwise ? CGFloat(constants.twoSeventyDegrees * M_PI / 180) : CGFloat(-internalProgress * M_PI / 180.0)
        
        progressPath.addArcWithCenter(center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
        progressPath.addLineToPoint(CGPointMake(progressRect.midX, progressRect.midY))
        progressPath.closePath()
        
        CGContextSaveGState(context)
        
        progressPath.addClip()
        
        if trackImage != nil {
            trackImage!.drawInRect(innerRect)
        } else {
            trackFillColor.setFill()
            circlePath.fill()
        }
        
        CGContextRestoreGState(context)
        
        // center Drawing
        let centerPath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX + trackWidth, innerRect.minY + trackWidth, CGRectGetWidth(innerRect) - (2 * trackWidth), CGRectGetHeight(innerRect) - (2 * trackWidth)))
        centerFillColor.setFill()
        centerPath.fill()
        
        if let centerImage = centerImage {
            CGContextSaveGState(context)
            centerPath.addClip()
            centerImage.drawInRect(rect)
            CGContextRestoreGState(context)
        } else {
            let layer = CAShapeLayer()
            layer.path = centerPath.CGPath
            contentView.layer.mask = layer
        }
        
        if self.displayValueInCenter {
            if let l = self.textLabel {
                if self.centerValueAsPercentage {
                    l.attributedText = NSAttributedString(string: "\(Int(round(progress * 100)))%")
                } else {
                    l.attributedText = NSAttributedString(string: "\(String(format: "%.2f", arguments: [progress]))")
                }
            }
        }
    }
    
    //MARK: - Progress Update
    
    public func setProgress(newProgress: Double, animated: Bool) {
        
        if animated {
            destinationProgress = newProgress
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        } else {
            progress = newProgress
        }
    }
    
    //MARK: - CADisplayLink Tick
    
    internal func displayLinkTick() {
        
        let renderTime = displayLink!.duration
        
        if destinationProgress > progress {
            progress += renderTime
            if progress >= destinationProgress {
                progress = destinationProgress
                displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                return
            }
        }
        
        if destinationProgress < progress {
            progress -= renderTime
            if progress <= destinationProgress {
                progress = destinationProgress
                displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                return
            }
        }
    }
    
    
}
