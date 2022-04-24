/**
 © Copyright 2022, The Great Rift Valley Software Company

 LICENSE:

 MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.0.0
*/

import UIKit

// MARK: -
// MARK: - Internal Extension Utilities -

/* ###################################################################################################################################### */
// MARK: - Private BinaryInteger Extension For Accessing UInt Components -
/* ###################################################################################################################################### */
fileprivate extension BinaryInteger {
    /**
     This comes pretty much [directly from here](https://www.hackingwithswift.com/example-code/language/how-to-split-an-integer-into-an-array-of-its-digits)
     */
    var digits: [Int] { String(describing: self).compactMap { Int(String($0)) } }
}

/* ###################################################################################################################################### */
// MARK: - Private CGPoint Extension For Rotating Points -
/* ###################################################################################################################################### */
fileprivate extension CGPoint {
    /* ################################################################## */
    /**
     Rotate this point around a given point, by an angle given in degrees.
     
     - parameters:
        - around: Another point, that is the "fulcrum" of the rotation.
        - byDegrees: The rotation angle, in degrees. 0 is no change. - is counter-clockwise, + is clockwise.
     - returns: The transformed point.
     */
    func _rotated(around inCenter: CGPoint, byDegrees inDegrees: CGFloat) -> CGPoint { _rotated(around: inCenter, byRadians: (inDegrees * .pi) / 180) }
    
    /* ################################################################## */
    /**
     This was inspired by [this SO answer](https://stackoverflow.com/a/35683523/879365).
     Rotate this point around a given point, by an angle given in radians.
     
     - parameters:
        - around: Another point, that is the "fulcrum" of the rotation.
        - byDegrees: The rotation angle, in radians. 0 is no change. - is counter-clockwise, + is clockwise.
     - returns: The transformed point.
     */
    func _rotated(around inCenter: CGPoint, byRadians inRadians: CGFloat) -> CGPoint {
        let dx = x - inCenter.x
        let dy = y - inCenter.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + inRadians
        let x = inCenter.x + radius * cos(newAzimuth)
        let y = inCenter.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}

// MARK: -
// MARK: - Main Implementation -

/* ###################################################################################################################################### */
// MARK: LED Element Protocol
/* ###################################################################################################################################### */
/**
 This protocol specifies the interface for an element that is to be incorporated into an LED display group.
 The idea of this file is to provide LED elements that are expressed as UIBezierPath objects.
 
 The deal with classes that use this protocol, is that they will deliver their displays as UIBezierPath objects, which can be resized, filled,
 combined with other paths, rotated, etc.
 */
protocol LED_Element {
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    var allSegments: UIBezierPath {get}
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    var activeSegments: UIBezierPath {get}
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    var inactiveSegments: UIBezierPath {get}
    
    /* ################################################################## */
    /**
     Get the drawing size of this element (or set of elements).
     This size is really a "baseline." It is probably not the size the digits will actually be rendered at.
     It should be used as a way to get a "starting point" for scaling and aspect ratio purposes.
     */
    var drawingSize: CGSize {get}
    
    /* ################################################################## */
    /**
     This is the value that is assigned to the element (or set of elements).
     */
    var value: Int {get set}
    
    /* ################################################################## */
    /**
     This is the number of digits, represented by this instance.
     */
    var numberOfDigits: Int {get}
    
    /* ################################################################## */
    /**
     The maximum value of this Array.
     */
    var maxVal: Int {get}
}

/* ###################################################################################################################################### */
// MARK: LED Element Protocol Defaults
/* ###################################################################################################################################### */
extension LED_Element {
    /* ################################################################## */
    /**
     The maximum value of this Array (it is calculated by default, from the number of digits).
     */
    var maxVal: Int { max(Int.max, Int(pow(Double(16), Double(numberOfDigits))) - 1) }
}

/* ###################################################################################################################################### */
// MARK: - "LED Single Digit" Class -
/* ###################################################################################################################################### */
/**
 This class represents a single LED digit.
 It will create paths that represent the digit, from -1 to 15. -1 is just the center segment (minus sign), and 10 - 15 are A, b, C, d E, F
 
 The size these paths are generated at is designed to produce a "standard LED Display" aspect with integer values.
 
 Each digit is treated as a "classic" Hex LED, with values that go from 0-F.
 If you give it a value of -1, then only a minus sign (center segment) is displayed.
 If you give it a value of -2, then nothing is displayed.
 
 We set up an arbitrary size of 250 X 492 as the control size, as it allows us to size things.
 However, it is expected that the control will be rendered at sizes more related to implementation.
 */
class LED_SingleDigit {
    /* ################################################################## */
    // MARK: Class Enums
    /* ################################################################## */
    /// These are indexes, used to make it a bit more apparent what segment is being sought.
    enum SegmentIndexes {
        /// top segment
        case kTopSegment
        /// top left segment
        case kTopLeftSegment
        /// top right segment
        case kTopRightSegment
        /// bottom left segment
        case kBottomLeftSegment
        /// bottom right segment
        case kBottomRightSegment
        /// bottom Segment
        case kBottomSegment
        /// center segment
        case kCenterSegment
    }
    
    /* ################################################################## */
    // MARK: Private Class Constants
    /* ################################################################## */
    /// These provide the indexes for selected values
    private static let _c_g_segmentSelection: [[SegmentIndexes]] = [
        [],
        [.kCenterSegment],
        [.kTopSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomLeftSegment, .kBottomSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopLeftSegment, .kCenterSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kBottomRightSegment, .kBottomSegment, .kTopLeftSegment],
        [.kCenterSegment, .kBottomRightSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kTopSegment],
        [.kTopSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomRightSegment, .kTopRightSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomRightSegment, .kTopRightSegment],
        [.kCenterSegment, .kBottomSegment, .kBottomLeftSegment, .kBottomRightSegment, .kTopLeftSegment],
        [.kTopSegment, .kBottomSegment, .kBottomLeftSegment, .kTopLeftSegment],
        [.kCenterSegment, .kBottomRightSegment, .kTopRightSegment, .kBottomLeftSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment, .kBottomSegment],
        [.kTopSegment, .kCenterSegment, .kTopLeftSegment, .kBottomLeftSegment]
    ]
    
    /* ################################################################## */
    /// This is an array of points that maps out the standard element shape.
    private static let _c_g_StandardShapePoints: [CGPoint] = [
        CGPoint(x: 0, y: 4),
        CGPoint(x: 4, y: 0),
        CGPoint(x: 230, y: 0),
        CGPoint(x: 234, y: 4),
        CGPoint(x: 180, y: 58),
        CGPoint(x: 54, y: 58),
        CGPoint(x: 0, y: 4)
    ]
    
    /* ################################################################## */
    /// This maps out the center element, which is a slightly different shape.
    private static let _c_g_CenterShapePoints: [CGPoint] = [
        CGPoint(x: 0, y: 34),
        CGPoint(x: 34, y: 0),
        CGPoint(x: 200, y: 0),
        CGPoint(x: 234, y: 34),
        CGPoint(x: 200, y: 68),
        CGPoint(x: 34, y: 68),
        CGPoint(x: 0, y: 34)
    ]
    
    /* ################################################################## */
    /// This array of points dictates the layout of the display.
    private static let _c_g_viewOffsets: [SegmentIndexes: CGPoint] = [
        .kTopSegment: CGPoint(x: 8, y: 0),               /// top segment
        .kTopLeftSegment: CGPoint(x: 0, y: 8),           /// top left segment
        .kTopRightSegment: CGPoint(x: 192, y: 8),        /// top right segment
        .kBottomLeftSegment: CGPoint(x: 0, y: 250),      /// bottom left segment
        .kBottomRightSegment: CGPoint(x: 192, y: 250),   /// bottom right segment
        .kBottomSegment: CGPoint(x: 8, y: 434),          /// bottom Segment
        .kCenterSegment: CGPoint(x: 8, y: 212)           /// center segment
    ]
    
    /* ################################################################## */
    /// This is the size of the entire drawing area.
    private static let _c_g_displaySize = CGSize(width: 250, height: 492)
    
    /* ################################################################## */
    // MARK: Private Instance Constants
    /* ################################################################## */
    /// The bezier path for the top segment
    private let _topSegment: UIBezierPath?
    /// The bezier path for the top, left segment
    private let _topLeftSegment: UIBezierPath?
    /// The bezier path for the bottom, left segment
    private let _bottomLeftSegment: UIBezierPath?
    /// The bezier path for the top, right segment
    private let _topRightSegment: UIBezierPath?
    /// The bezier path for the bottom, right segment
    private let _bottomRightSegment: UIBezierPath?
    /// The bezier path for the bottom segment
    private let _bottomSegment: UIBezierPath?
    /// The bezier path for the center segment
    private let _centerSegment: UIBezierPath?

    /* ################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################## */
    /**
     The value expressed by this instance -2...15
     */
    private var _value: Int = -2
    
    /* ################################################################## */
    // MARK: Initializer
    /* ################################################################## */
    /**
     Instantiates each of the segments.
     
     - parameter inValue: value, from -2 to 15 (-2 is nothing. -1 is the minus sign).
     */
    init(_ inValue: Int) {
        _topSegment = Self._newSegmentShape(inSegment: .kTopSegment)
        _topLeftSegment = Self._newSegmentShape(inSegment: .kTopLeftSegment)
        _bottomLeftSegment = Self._newSegmentShape(inSegment: .kBottomLeftSegment)
        _topRightSegment = Self._newSegmentShape(inSegment: .kTopRightSegment)
        _bottomRightSegment = Self._newSegmentShape(inSegment: .kBottomRightSegment)
        _bottomSegment = Self._newSegmentShape(inSegment: .kBottomSegment)
        _centerSegment = Self._newSegmentShape(inSegment: .kCenterSegment)
        value = inValue
    }
}

/* ###################################################################################################################################### */
// MARK: Private Class Functions
/* ###################################################################################################################################### */
extension LED_SingleDigit {
    /* ################################################################## */
    // MARK: Private Class Functions
    /* ################################################################## */
    /**
     Creates a path containing a segment shape.
     
     - parameter inSegment: This indicates which segment we want (Will affect rotation and selection of shape).
     
     - returns: a new path, in the shape of the requested segment
     */
    private class func _newSegmentShape(inSegment: SegmentIndexes) -> UIBezierPath {
        let ret = UIBezierPath()
        
        let points: [CGPoint] = (.kCenterSegment == inSegment) ? _c_g_CenterShapePoints: _c_g_StandardShapePoints
        
        ret.move(to: (points[0]))
        
        _ = points.map { ret.addLine(to: $0) }
        
        ret.addLine(to: points[0])
        
        var rotDiv: CGFloat = 0.0
        
        switch inSegment {
        case .kTopLeftSegment:
            rotDiv = CGFloat(Double.pi / -2.0)
        case .kBottomLeftSegment:
            rotDiv = CGFloat(Double.pi / -2.0)
        case .kTopRightSegment:
            rotDiv = CGFloat(Double.pi / 2.0)
        case .kBottomRightSegment:
            rotDiv = CGFloat(Double.pi / 2.0)
        case .kBottomSegment:
            rotDiv = -CGFloat(Double.pi)
        default:
            break
        }
        
        let rotation = CGAffineTransform(rotationAngle: rotDiv)
        ret.apply(rotation)
        let bounds = ret.cgPath.boundingBox
        if let offset = _c_g_viewOffsets[inSegment] {
            var toOrigin: CGAffineTransform
            switch inSegment {
            case .kBottomSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
            case .kTopLeftSegment:
                toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
            case .kBottomLeftSegment:
                toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
            case .kTopRightSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
            case .kBottomRightSegment:
                toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
            default:
                toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
            }
            ret.apply(toOrigin)
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension LED_SingleDigit {
    /* ################################################################## */
    /**
     Returns true, if the segment is selected for the current value.
     
     - parameter inSegment: This indicates which segment we want to test.
     
     - returns: true, if the segment is selected, false, otherwise
     */
    private func _isSegmentSelected(_ inSegment: SegmentIndexes) -> Bool {
        var ret: Bool = false
        let selectedSegments = Self._c_g_segmentSelection[_value + 2]
    
        for segmentPathIndex in selectedSegments where segmentPathIndex == inSegment {
            ret = true
            break
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: LED_Element Conformance
/* ###################################################################################################################################### */
extension LED_SingleDigit: LED_Element {
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    var allSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        if let path = _topSegment {
            ret.append(path)
        }
        
        if let path = _topLeftSegment {
            ret.append(path)
        }
        
        if let path = _bottomLeftSegment {
            ret.append(path)
        }
        
        if let path = _topRightSegment {
            ret.append(path)
        }
        
        if let path = _bottomRightSegment {
            ret.append(path)
        }
        
        if let path = _bottomSegment {
            ret.append(path)
        }
        
        if let path = _centerSegment {
            ret.append(path)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    var activeSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        let selectedSegments = Self._c_g_segmentSelection[_value + 2]
        // Include the segments that we're using.
        selectedSegments.forEach {
            switch $0 {
            case .kCenterSegment:
                if let centerSegment = _centerSegment {
                    ret.append(centerSegment)
                }
            case .kTopSegment:
                if let topSegment = _topSegment {
                    ret.append(topSegment)
                }
            case .kBottomSegment:
                if let bottomSegment = _bottomSegment {
                    ret.append(bottomSegment)
                }
            case .kTopLeftSegment:
                if let topLeftSegment = _topLeftSegment {
                    ret.append(topLeftSegment)
                }
            case .kTopRightSegment:
                if let topRightSegment = _topRightSegment {
                    ret.append(topRightSegment)
                }
            case .kBottomLeftSegment:
                if let bottomLeftSegment = _bottomLeftSegment {
                    ret.append(bottomLeftSegment)
                }
            case .kBottomRightSegment:
                if let bottomRightSegment = _bottomRightSegment {
                    ret.append(bottomRightSegment)
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    var inactiveSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        // We only include the ones that we're not using.
        if !_isSegmentSelected(.kTopSegment) {
            if let path = _topSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kTopLeftSegment) {
            if let path = _topLeftSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kBottomLeftSegment) {
            if let path = _bottomLeftSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kTopRightSegment) {
            if let path = _topRightSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kBottomRightSegment) {
            if let path = _bottomRightSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kBottomSegment) {
            if let path = _bottomSegment {
                ret.append(path)
            }
        }
        
        if !_isSegmentSelected(.kCenterSegment) {
            if let path = _centerSegment {
                ret.append(path)
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get the bounding box of this segment.
     */
    var drawingSize: CGSize {
        return Self._c_g_displaySize
    }
    
    /* ################################################################## */
    /**
     Public accessor for the value of this digit (-1 through 15).
     */
    var value: Int {
        get { return _value }
        set { _value = max(-2, min(15, newValue)) }
    }
    
    /* ################################################################## */
    /**
     This is the number of digits, represented by this instance.
     In this class, it is always 1.
     */
    var numberOfDigits: Int { 1 }
}

/* ###################################################################################################################################### */
// MARK: - "LED Multiple Digit" Class -
/* ###################################################################################################################################### */
/**
 */
class LED_MultipleDigits {
    /* ################################################################## */
    /**
     This is a linear array of digits.
     This array has them all, and they are arranged as a single number, from MSB (left) to LSB (right).
     No separators or decimal points. Those should be provided separately.
     The first element [0] in the array will be the MSB, and the last will be the LSB.
     */
    private var _digitArray: [LED_SingleDigit] = []

    /* ################################################################## */
    // MARK: Initializer
    /* ################################################################## */
    /**
     - parameter inValue: value, from -2 to maxVal.
     - parameter numberOfDigits: The number of digits. This should be enough to hold the value. If not specified, then it is 1.
     */
    init(_ inValue: Int, numberOfDigits inNumberOfDigits: Int = 1) {
        for _ in 0..<inNumberOfDigits { _digitArray.append(LED_SingleDigit(0)) }
        value = inValue
    }
}

/* ###################################################################################################################################### */
// MARK: LED_Element Conformance
/* ###################################################################################################################################### */
extension LED_MultipleDigits: LED_Element {
    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    var allSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        _digitArray.forEach { ret.append($0.allSegments) }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    var activeSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        _digitArray.forEach { ret.append($0.activeSegments) }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    var inactiveSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        _digitArray.forEach { ret.append($0.inactiveSegments) }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Get the drawing size of this set of elements.
     The bezier paths will all be within a bounds rect, of this size (origin: 0, 0).
     This size is really a "baseline." It is probably not the size the digits will actually be rendered at.
     It should be used as a way to get a "starting point" for scaling and aspect ratio purposes.
     This assumes that each element is horizontally attached to the next, so the size is the sum of all elements, horizontally, and the largest element, vertically.
     */
    var drawingSize: CGSize {
        var ret = CGSize.zero
        
        _digitArray.forEach {
            ret.width += $0.drawingSize.width
            ret.height = max(ret.height, $0.drawingSize.height)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is the value that is assigned to the set of elements.
     This will be expressed as a hexadecimal value (so each element is -2...15).
     If -2, then the entire array is hidden.
     If -1, the array is a line of center segments.
     0...valueMax has more significant digit segments hidden (internally, -2).
     This will not display negative values (no -A, for example).
     */
    var value: Int {
        get {
            return _digitArray.reduce(0) { current, next in
                if 0 <= next.value {
                    return (current * 16) + next.value
                } else if -1 == next.value {
                    return -1
                } else {
                    return -2
                }
            }
        }
        
        set {
            let totalValue = max(-2, min(maxVal, newValue))
            
            if 0 > totalValue {
                _digitArray.forEach { $0.value = totalValue }
            } else {
                var index = numberOfDigits - 1
                totalValue.digits.reversed().forEach {
                    _digitArray[index].value = $0
                    index += 1
                }
                // We hide the rest.
                while 0 < index {
                    _digitArray[index].value = -2
                }
            }
        }
    }

    /* ################################################################## */
    /**
     Returns the number of digits, represented by this array.
     */
    var numberOfDigits: Int { _digitArray.count }
}

/* ###################################################################################################################################### */
// MARK: - Retro LED Display As An Image View -
/* ###################################################################################################################################### */
/**
 The display is a subclass of UIImageView. We do this, so we can easily have a background image.
 */
open class RVS_RetroLEDDisplayBase: UIImageView {
    /* ################################################################## */
    /**
     This holds the instance that will generate the paths we use for display.
     */
    private var _digitFactory: LED_MultipleDigits?
    
    /* ################################################################## */
    /**
     This caches the original background color. It is set at load time.
     */
    private var _originalBackgroundColor: UIColor?
    
    /* ################################################################## */
    /**
     This caches the original tint color. It is set at load time.
     */
    private var _originalTintColor: UIColor?

    /* ################################################################## */
    /**
     This caches the gradient layer for the "On" segments. This is set when the gradient is redrawn.
     If this is not-nil, then it will be fetched, instead of redrawing the gradient.
     In order to force the gradient to redraw, set this to nil.
     */
    private var _onGradientLayer: CAGradientLayer?

    /* ################################################################## */
    /**
     The starting color for the gradient.
     */
    private var _onGradientStartColor: UIColor? {
        didSet {
            _onGradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The ending color.
     */
    private var _onGradientEndColor: UIColor? {
        didSet {
            _onGradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees.
     */
    private var _onGradientAngleInDegrees: CGFloat = 0 {
        didSet {
            _onGradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     This caches the gradient layer for the "Off" segments. This is set when the gradient is redrawn.
     If this is not-nil, then it will be fetched, instead of redrawing the gradient.
     In order to force the gradient to redraw, set this to nil.
     */
    private var _offGradientLayer: CAGradientLayer?

    /* ################################################################## */
    /**
     The starting color for the gradient.
     */
    private var _offGradientStartColor: UIColor? {
        didSet {
            _offGradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The ending color.
     */
    private var _offGradientEndColor: UIColor? {
        didSet {
            _offGradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees.
     */
    private var _offGradientAngleInDegrees: CGFloat = 0 {
        didSet {
            _offGradientLayer = nil
            setNeedsLayout()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Private Computed Properties
/* ###################################################################################################################################### */
private extension RVS_RetroLEDDisplayBase {
    /* ################################################################## */
    /**
     This returns the background gradient layer, rendering it, if necessary.
     */
    var _fetchGradientLayer: CALayer? { _makeGradientLayer() }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
private extension RVS_RetroLEDDisplayBase {
    /* ################################################################## */
    /**
     This creates the gradient layer, using our specified start and stop colors.
     If the gradient cache is available, we immediately return that, instead.
     */
    func _makeGradientLayer() -> CALayer? {
        guard nil == _onGradientLayer else { return _onGradientLayer }
        
        // We try to get whatever the user explicitly set. If not that, then a background color, then the tint color (both ours and super), and, finally, the accent color. If not that, we give up.
        if let startColor = onGradientStartColor ?? _originalBackgroundColor ?? _originalTintColor ?? superview?.tintColor ?? UIColor(named: "AccentColor") {
            let endColor = onGradientEndColor ?? startColor
            _onGradientLayer = CAGradientLayer()
            _onGradientLayer?.frame = bounds
            _onGradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
            _onGradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: onGradientAngleInDegrees)
            _onGradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: onGradientAngleInDegrees)
        } else {
            assertionFailure("No Starting Color Provided for the RVS_MaskButton class!")
        }
        
        return _onGradientLayer
    }
}

/* ###################################################################################################################################### */
// MARK: Public Computed Properties
/* ###################################################################################################################################### */
public extension RVS_RetroLEDDisplayBase {
    /* ################################################################## */
    /**
     The starting color for the "On" gradient.
     If not provided, the view backgroundColor is used.
     If that is not provided, then the view tintColor is used.
     If that is not provided, then the super (parent) view tintColor is used.
     If that is not provided, the AccentColor is used.
     If that is not provided, the class will not work.
     */
    @IBInspectable var onGradientStartColor: UIColor? {
        get { _onGradientStartColor }
        set { _onGradientStartColor = newValue }
    }

    /* ################################################################## */
    /**
     The ending color. If not provided, then the starting color is used.
     */
    @IBInspectable var onGradientEndColor: UIColor? {
        get { _onGradientEndColor }
        set { _onGradientEndColor = newValue }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees. 0 (default) is top-to-bottom.
     Zero is top-to-bottom.
     Negative is counter-clockwise, and positive is clockwise.
     */
    @IBInspectable var onGradientAngleInDegrees: CGFloat {
        get { _onGradientAngleInDegrees }
        set { _onGradientAngleInDegrees = newValue }
    }

    /* ################################################################## */
    /**
     The starting color for the "Off" gradient.
     If not provided, the view backgroundColor is used.
     If that is not provided, then the view tintColor is used.
     If that is not provided, then the super (parent) view tintColor is used.
     If that is not provided, the AccentColor is used.
     If that is not provided, the class will not work.
     */
    @IBInspectable var offGradientStartColor: UIColor? {
        get { _offGradientStartColor }
        set { _offGradientStartColor = newValue }
    }

    /* ################################################################## */
    /**
     The ending color. If not provided, then the starting color is used.
     */
    @IBInspectable var offGradientEndColor: UIColor? {
        get { _offGradientEndColor }
        set { _offGradientEndColor = newValue }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees. 0 (default) is top-to-bottom.
     Zero is top-to-bottom.
     Negative is counter-clockwise, and positive is clockwise.
     */
    @IBInspectable var offGradientAngleInDegrees: CGFloat {
        get { _offGradientAngleInDegrees }
        set { _offGradientAngleInDegrees = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - Retro LED Display (Single LED Digit) -
/* ###################################################################################################################################### */
/**
 */
@IBDesignable
open class RVS_RetroLEDSingleDigitDisplay: RVS_RetroLEDDisplayBase {
    /* ################################################################################################################################## */
    // MARK: Private Stored Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the LED digit that is used to produce the bezier paths for this display.
     */
    private var _ledPathMaker: LED_SingleDigit?
}

/* ###################################################################################################################################### */
// MARK: Public Computed Properties
/* ###################################################################################################################################### */
public extension RVS_RetroLEDSingleDigitDisplay {
    /* ################################################################## */
    /**
     This is the value that is to be displayed. It can be -2 (not shown), -1 (negative sign), or 0-15 (10-15 are A, b, C, d, E, and F).
     */
    @IBInspectable var value: Int {
        get { _ledPathMaker?.value ?? -2 }
        set {
            if (-2..<16).contains(newValue) {
                _ledPathMaker = LED_SingleDigit(newValue)
                setNeedsDisplay()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public Base Class Overrides
/* ###################################################################################################################################### */
public extension RVS_RetroLEDSingleDigitDisplay {
    /* ################################################################## */
    /**
     Called to render this image.
     
     - parameter inDrawingRect: The rect in which to render the digit.
     */
    override func draw(_ inDrawingRect: CGRect) {
    }
}
