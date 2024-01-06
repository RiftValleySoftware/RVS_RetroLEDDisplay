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
 
 Version 1.4.5
*/

import UIKit

/* ###################################################################################################################################### */
// MARK: -
// MARK: - Internal Extension Utilities -
// MARK: -
/* ###################################################################################################################################### */
// MARK: UIImage Extension -
/* ###################################################################################################################################### */
/**
 This adds some simple image manipulation.
 */
extension UIImage {
    /* ################################################################## */
    /**
     This allows an image to be resized, given a maximum dimension, and a scale will be determined to meet that dimension.
     
     - parameters:
         - toScaleFactor: The scale of the resulting image, as a multiplier of the current size.
     
     - returns: A new image, with the given scale. May be nil, if there was an error.
     */
    func resized(toScaleFactor inScaleFactor: CGFloat) -> UIImage? { resized(toNewWidth: size.width * inScaleFactor, toNewHeight: size.height * inScaleFactor) }
    
    /* ################################################################## */
    /**
     This allows an image to be resized, given both a width and a height, or just one of the dimensions.
     
     - parameters:
         - toNewWidth: The width (in pixels) of the desired image. If not provided, a scale will be determined from the toNewHeight parameter.
         - toNewHeight: The height (in pixels) of the desired image. If not provided, a scale will be determined from the toNewWidth parameter.
     
     - returns: A new image, with the given dimensions. May be nil, if no width or height was supplied, or if there was an error.
     */
    func resized(toNewWidth inNewWidth: CGFloat? = nil, toNewHeight inNewHeight: CGFloat? = nil) -> UIImage? {
        guard nil == inNewWidth,
              nil == inNewHeight else {
            var scaleX: CGFloat = (inNewWidth ?? size.width) / size.width
            var scaleY: CGFloat = (inNewHeight ?? size.height) / size.height

            scaleX = nil == inNewWidth ? scaleY : scaleX
            scaleY = nil == inNewHeight ? scaleX : scaleY

            let destinationSize = CGSize(width: size.width * scaleX, height: size.height * scaleY)
            let destinationRect = CGRect(origin: .zero, size: destinationSize)

            UIGraphicsBeginImageContextWithOptions(destinationSize, false, 0)
            defer { UIGraphicsEndImageContext() }   // This makes sure that we get rid of the offscreen context.
            draw(in: destinationRect, blendMode: .normal, alpha: 1)
            return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode)
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - Private BinaryInteger Extension For Accessing UInt Components -
/* ###################################################################################################################################### */
fileprivate extension BinaryInteger {
    /* ################################################################## */
    /**
     Returns an array of integers; each representing the numerical value of the integer, as a binary number (0...1).
     > The first "digit" could be a negative sign.
     */
    var binaryDigits: [Int] { String(self, radix: 2).compactMap { Int(String($0), radix: 2) } }

    /* ################################################################## */
    /**
     Returns an array of integers; each representing the numerical value of the integer, as an octal number (0...7).
     > The first "digit" could be a negative sign.
     */
    var octalDigits: [Int] { String(self, radix: 8).compactMap { Int(String($0), radix: 8) } }

    /* ################################################################## */
    /**
     Returns an array of integers; each representing the numerical value of the integer, as a decimal number (0...9).
     > The first "digit" could be a negative sign.
     */
    var decimalDigits: [Int] { String(self).compactMap { Int(String($0)) } }

    /* ################################################################## */
    /**
     Returns an array of integers; each representing the numerical value of the integer, as a hexadecimal number (0...F).
     > The first "digit" could be a negative sign.
     */
    var hexDigits: [Int] { String(self, radix: 16).compactMap { Int(String($0), radix: 16) } }
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

/* ###################################################################################################################################### */
// MARK: - Private UIColor Extension For Inverting Colors -
/* ###################################################################################################################################### */
fileprivate extension UIColor {
    /* ################################################################## */
    /**
     Returns the inverted color.
     NOTE: This is quite primitive, and may not return exactly what may be expected.
     [From This SO Answer](https://stackoverflow.com/a/57111280/879365)
     */
    var inverted: UIColor {
        var a: CGFloat = 0.0, r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a) : .label
    }
}

/* ###################################################################################################################################### */
// MARK: -
// MARK: - Main Implementation -
// MARK: -
/* ###################################################################################################################################### */
// MARK: LED Element Protocol -
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
    
    /* ################################################################## */
    /**
     The ideal aspect ratio (X / Y) of the display.
     */
    var idealAspect: CGFloat {get}
    
    /* ################################################################## */
    /**
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    var radix: Int {get set}
}

/* ###################################################################################################################################### */
// MARK: LED Element Protocol Defaults
/* ###################################################################################################################################### */
extension LED_Element {
    /* ################################################################## */
    /**
     The maximum value of this Array (it is calculated by default, from the number of digits).
     */
    var maxVal: Int { min(Int.max, Int(pow(Double(radix), Double(numberOfDigits))) - 1) }
    
    /* ################################################################## */
    /**
     The ideal aspect ratio (X / Y) of the display.
     */
    var idealAspect: CGFloat { drawingSize.width / drawingSize.height }
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
    /**
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    private var _radix: Int = 16

    /* ################################################################## */
    // MARK: Initializer
    /* ################################################################## */
    /**
     Instantiates each of the segments.
     
     - parameter inValue: value, from -2 to 15 (-2 is nothing. -1 is the minus sign).
     - parameter radix: The numbering base to use for this display. Default is 16
     */
    init(_ inValue: Int, radix inRadix: Int = 16) {
        _topSegment = Self._newSegmentShape(inSegment: .kTopSegment)
        _topLeftSegment = Self._newSegmentShape(inSegment: .kTopLeftSegment)
        _bottomLeftSegment = Self._newSegmentShape(inSegment: .kBottomLeftSegment)
        _topRightSegment = Self._newSegmentShape(inSegment: .kTopRightSegment)
        _bottomRightSegment = Self._newSegmentShape(inSegment: .kBottomRightSegment)
        _bottomSegment = Self._newSegmentShape(inSegment: .kBottomSegment)
        _centerSegment = Self._newSegmentShape(inSegment: .kCenterSegment)
        radix = inRadix
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
        
        points.forEach { ret.addLine(to: $0) }
        
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
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    var radix: Int {
        get { _radix }
        set {
            guard 2 == newValue || 8 == newValue || 10 == newValue || 16 == newValue else { return }
            _radix = newValue
        }
    }

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
        if !_isSegmentSelected(.kTopSegment),
           let path = _topSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kTopLeftSegment),
           let path = _topLeftSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kBottomLeftSegment),
           let path = _bottomLeftSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kTopRightSegment),
           let path = _topRightSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kBottomRightSegment),
           let path = _bottomRightSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kBottomSegment),
           let path = _bottomSegment {
            ret.append(path)
        }
        
        if !_isSegmentSelected(.kCenterSegment),
           let path = _centerSegment {
            ret.append(path)
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
        set { _value = max(-2, min(radix - 1, newValue)) }
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
 This aggregates multiple single digits, into a row of them, and treats the row as an MSB -> LSB hex value.
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
    /**
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    private var _radix: Int = 16

    /* ################################################################## */
    /**
     This is how many calculation (not display) units separate each digit. Default is 10.
     */
    var gap: CGFloat = 10.0

    /* ################################################################## */
    /**
     This is true, if the value is to be displayed with leading zeroes.
     */
    var hasLeadingZeroes: Bool = false

    /* ################################################################## */
    // MARK: Initializer
    /* ################################################################## */
    /**
     - parameter inValue: value, from -2 to maxVal.
     - parameter numberOfDigits: The number of digits. This should be enough to hold the value. If not specified, then it is 1.
     - parameter radix: The numbering base to use for this display. Default is 16.
     - parameter gap: The gap, in computational units (not display units). The default is 10.
     - parameter hasLeadingZeroes: If true (default is false), then the display is made with leading zeroes (blank, otherwise).
     */
    init(_ inValue: Int,
         numberOfDigits inNumberOfDigits: Int = 1,
         radix inRadix: Int = 16,
         gap inGap: CGFloat = 10,
         hasLeadingZeroes inHasLeadingZeroes: Bool = false
    ) {
        for _ in 0..<inNumberOfDigits { _digitArray.append(LED_SingleDigit(0, radix: inRadix)) }
        gap = inGap
        value = inValue
        hasLeadingZeroes = inHasLeadingZeroes
    }
}

/* ###################################################################################################################################### */
// MARK: LED_Element Conformance
/* ###################################################################################################################################### */
extension LED_MultipleDigits: LED_Element {
    /* ################################################################## */
    /**
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    var radix: Int {
        get { _radix }
        set {
            guard 2 == newValue || 8 == newValue || 10 == newValue || 16 == newValue else { return }
            _radix = newValue
            _digitArray.forEach { $0.radix = newValue }
        }
    }

    /* ################################################################## */
    /**
     Get all segments as one path.
     */
    var allSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        var xOffset: CGFloat = 0
        
        _digitArray.forEach {
            let transform = CGAffineTransform(translationX: xOffset, y: 0)
            xOffset += ($0.drawingSize.width + gap)
            let paths = $0.allSegments
            paths.apply(transform)
            ret.append(paths)
        }

        return ret
    }
    
    /* ################################################################## */
    /**
     Get "active" segments as one path.
     */
    var activeSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        var xOffset: CGFloat = 0
        
        _digitArray.forEach {
            let transform = CGAffineTransform(translationX: xOffset, y: 0)
            xOffset += ($0.drawingSize.width + gap)
            let paths = $0.activeSegments
            paths.apply(transform)
            ret.append(paths)
        }

        return ret
    }
    
    /* ################################################################## */
    /**
     Get "inactive" segments as one path.
     */
    var inactiveSegments: UIBezierPath {
        let ret: UIBezierPath = UIBezierPath()
        
        var xOffset: CGFloat = 0
        
        _digitArray.forEach {
            let transform = CGAffineTransform(translationX: xOffset, y: 0)
            xOffset += ($0.drawingSize.width + gap)
            let paths = $0.inactiveSegments
            paths.apply(transform)
            ret.append(paths)
        }
        
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
        
        var gaps: CGFloat = 0
        
        _digitArray.forEach {
            ret.width += ($0.drawingSize.width + gaps)
            ret.height = max(ret.height, $0.drawingSize.height)
            gaps = gap
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
            guard _digitArray.contains(where: { -1 != $0.value }) else { return -1 }
            guard _digitArray.contains(where: { -2 != $0.value }) else { return -2 }
            return _digitArray.reduce(0) { current, next in
                if 0 <= next.value {
                    return (current * self.radix) + next.value
                } else {
                    return current
                }
            }
        }
        
        set {
            let totalValue = max(-2, min(maxVal, newValue))
            
            if 0 > totalValue {
                _digitArray.forEach { $0.value = totalValue }
            } else {
                _digitArray.forEach { $0.value = self.hasLeadingZeroes ? 0 : -2 }
                var digits: [Int]
                
                switch radix {
                case 2:
                    digits = totalValue.binaryDigits
                case 8:
                    digits = totalValue.octalDigits
                case 10:
                    digits = totalValue.decimalDigits
                case 16:
                    digits = totalValue.hexDigits
                default:
                    digits = []
                }

                var index = numberOfDigits - digits.count
                digits.forEach {
                    _digitArray[index].value = $0
                    index += 1
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
@IBDesignable
open class RVS_RetroLEDDigitalDisplay: UIImageView {
    /* ################################################################## */
    /**
     This is the default duration of change animations.
     */
    private static let _defaultAnimationDurationInSeconds: TimeInterval = 0.125

    /* ################################################################## */
    /**
     This is the opacity that is briefly set, when animating transitions.
     */
    private static let _animationOpacity = Float(0.9)

    /* ################################################################## */
    /**
     This holds the instance that will generate the paths we use for display.
     */
    private var _digitFactory: LED_MultipleDigits?

    /* ################################################################## */
    /**
     This caches the gradient layer for the "On" segments. This is set when the gradient is redrawn.
     If this is not-nil, then it will be fetched, instead of redrawing the gradient.
     In order to force the gradient to redraw, set this to nil.
     */
    private var _onColorLayer: CALayer?

    /* ################################################################## */
    /**
     This caches the gradient layer for the "Off" segments. This is set when the gradient is redrawn.
     If this is not-nil, then it will be fetched, instead of redrawing the gradient.
     In order to force the gradient to redraw, set this to nil.
     */
    private var _offColorLayer: CALayer?

    /* ################################################################## */
    /**
     The starting color for the gradient.
     */
    private var _onGradientStartColor: UIColor? {
        didSet {
            _clearOnColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The ending color.
     */
    private var _onGradientEndColor: UIColor? {
        didSet {
            _clearOnColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees.
     */
    private var _onGradientAngleInDegrees: CGFloat = 0 {
        didSet {
            _clearOnColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The starting color for the gradient.
     */
    private var _offGradientStartColor: UIColor? {
        didSet {
            _clearOffColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The ending color.
     */
    private var _offGradientEndColor: UIColor? {
        didSet {
            _clearOffColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees.
     */
    private var _offGradientAngleInDegrees: CGFloat = 0 {
        didSet {
            _clearOffColorLayer()
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     This is the LED digit[s] that is|are used to produce the bezier paths for this display.
     */
    private var _ledPathMaker: LED_MultipleDigits?

    /* ################################################################## */
    /**
     This image, if provided, will be used instead of a gradient, for the "active" LED segments.
     */
    private var _onImage: UIImage? {
        didSet {
            _clearOnColorLayer()
            setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     This allows you to apply a "skew" to the widget.
     This means that there is a "lean," like many classic LED displays.
     A positive skew, means that the widget "leans right," with the top moving right, and the bottom, moving left.
     A negative skew, is in the other direction.
     This is limited to -1...1.
     This will change the size of the widget, horizontally (but not vertically).
     */
    private var _skew: CGFloat = 0 { didSet { setNeedsLayout() } }
    
    /* ################################################################## */
    /**
     This is the duration of change animations.
     */
    private var _animationDurationInSeconds: TimeInterval = RVS_RetroLEDDigitalDisplay._defaultAnimationDurationInSeconds
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
private extension RVS_RetroLEDDigitalDisplay {
    /* ################################################################## */
    /**
     This completely removes the "On" color layer, so the next call of `_makeOnColorLayer()` will rebuild it.
     */
    private func _clearOnColorLayer() {
        _onColorLayer?.removeFromSuperlayer()
        _onColorLayer = nil
    }
    
    /* ################################################################## */
    /**
     This completely removes the "Off" color layer, so the next call of `_makeOffColorLayer()` will rebuild it.
     */
    private func _clearOffColorLayer() {
        _offColorLayer?.removeFromSuperlayer()
        _offColorLayer = nil
    }
    
    /* ################################################################## */
    /**
     This creates the "On" gradient/image layer, using our specified start and stop colors.
     If the gradient cache is available, we immediately return that, instead.
     - returns: The color layer (it has also been assigned to the `_onColorLayer` cache property).
     */
    @discardableResult
    func _makeOnColorLayer() -> CALayer? {
        guard nil == _onColorLayer
        else {
            _onColorLayer?.frame = bounds
            return _onColorLayer
        }

        if let image = _onImage?.resized(toNewWidth: bounds.width, toNewHeight: bounds.height)?.cgImage {
            _onColorLayer = CALayer()
            _onColorLayer?.frame = bounds
            _onColorLayer?.contents = image
        } else {
            // We try to get whatever the user explicitly set. If not that, then we use the label color.
            let startColor = onGradientStartColor ?? .clear
            let endColor = onGradientEndColor ?? startColor
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: onGradientAngleInDegrees)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: onGradientAngleInDegrees)
            _onColorLayer = gradientLayer
        }
        
        if let newLayer = _onColorLayer {
            layer.addSublayer(newLayer)
        }

        return _onColorLayer
    }
    
    /* ################################################################## */
    /**
     This creates the "Off" gradient/image layer, using our specified start and stop colors.
     If the gradient cache is available, we immediately return that, instead.
     - returns: The color layer (it has also been assigned to the `_offColorLayer` cache property).
     */
    @discardableResult
    func _makeOffColorLayer() -> CALayer? {
        guard nil == _offColorLayer else {
            _offColorLayer?.frame = bounds
            return _offColorLayer
        }
        
        if let image = image?.resized(toNewWidth: bounds.width, toNewHeight: bounds.height)?.cgImage {
            _offColorLayer = CALayer()
            _offColorLayer?.frame = bounds
            _offColorLayer?.contents = image
        } else {
            // We try to get whatever the user explicitly set. If not that, then we invert the label color.
            let startColor = offGradientStartColor ?? .clear
            let endColor = offGradientEndColor ?? startColor
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: offGradientAngleInDegrees)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: offGradientAngleInDegrees)
            _offColorLayer = gradientLayer
        }
        
        if let newLayer = _offColorLayer {
            layer.addSublayer(newLayer)
        }
        
        return _offColorLayer
    }
}

/* ###################################################################################################################################### */
// MARK: Public Computed Properties
/* ###################################################################################################################################### */
public extension RVS_RetroLEDDigitalDisplay {
    /* ################################################################## */
    /**
     This allows you to apply a "skew" to the widget.
     This means that there is a "lean," like many classic LED displays.
     A positive skew, means that the widget "leans right," with the top moving right, and the bottom, moving left.
     A negative skew, is in the other direction.
     This is limited to -1...1.
     This will change the size of the widget, horizontally (but not vertically).
     */
    @IBInspectable var skew: CGFloat {
        get { _skew }
        set { _skew = max(-1.0, min(1.0, newValue)) }
    }

    /* ################################################################## */
    /**
     This is the duration of change animations. Default is 1/8 of a second (125 mS). 0 disables the animation.
     */
    @IBInspectable var animationDurationInSeconds: CGFloat {
        get { CGFloat(_animationDurationInSeconds) }
        set { _animationDurationInSeconds = TimeInterval(newValue) }
    }

    /* ################################################################## */
    /**
     The starting color for the "On" gradient.
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

    /* ################################################################## */
    /**
     This is true, if values are to be displayed with leading zeores.
     */
    @IBInspectable var hasLeadingZeroes: Bool {
        get { _ledPathMaker?.hasLeadingZeroes ?? false }
        set {
            let oldValue = value
            _ledPathMaker?.hasLeadingZeroes = newValue
            _ledPathMaker?.value = oldValue
            DispatchQueue.main.async { self.setNeedsLayout() }
        }
    }
    
    /* ################################################################## */
    /**
     This is the number of digits for this group. 0 (or less), means no display.
     */
    @IBInspectable var numberOfDigits: Int {
        get { _ledPathMaker?.numberOfDigits ?? 0 }
        set {
            if 0 >= newValue {
                _ledPathMaker = nil
                DispatchQueue.main.async { self.setNeedsLayout() }
                return
            }
            guard nil == _ledPathMaker || _ledPathMaker?.numberOfDigits != newValue else { return }
            let currentHasLeadingZeroes = hasLeadingZeroes
            let currentValue = _ledPathMaker?.value ?? -2
            let currentRadix = _ledPathMaker?.radix ?? 16
            _ledPathMaker = LED_MultipleDigits(currentValue, numberOfDigits: newValue, radix: currentRadix, hasLeadingZeroes: currentHasLeadingZeroes)
            DispatchQueue.main.async { self.setNeedsLayout() }
        }
    }

    /* ################################################################## */
    /**
     This is how many calculation (not display) units separate each digit. Default is 8.
     */
    @IBInspectable var gap: CGFloat {
        get { _ledPathMaker?.gap ?? 0 }
        set {
            _ledPathMaker?.gap = newValue
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     This property allows you to assign an image to the on segments.
     If this is set to an image (non-nil), then that will supersede the gradient colors.
     */
    @IBInspectable var onImage: UIImage? {
        get { _onImage }
        set {
            _onImage = newValue
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     This is a numerical value to set to the collected digits.
     If we have an animation duration, the old value will fade.
     */
    @IBInspectable var value: Int {
        get { _ledPathMaker?.value ?? -2 }
        set {
            if let oldValue = _ledPathMaker?.value,
               oldValue != newValue {
                _ledPathMaker?.value = newValue
                if 0 < animationDurationInSeconds {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(CFTimeInterval(animationDurationInSeconds))
                    CATransaction.setCompletionBlock({ [weak self] in
                        self?._clearOnColorLayer()
                        self?._clearOffColorLayer()
                        self?.setNeedsLayout()
                    })
                    _onColorLayer?.opacity = Self._animationOpacity
                    CATransaction.commit()
                } else {
                    _clearOnColorLayer()
                    _clearOffColorLayer()
                    setNeedsLayout()
                }
            }
        }
    }

    /* ################################################################## */
    /**
     Read-only value that returns the minimum possible value for this instance (always -2).
     */
    var minValue: Int { -2 }

    /* ################################################################## */
    /**
     Read-only value that returns the maximum possible value for this instance.
     */
    var maxValue: Int {
        let max = _ledPathMaker?.maxVal ?? minValue
        return max
    }
    
    /* ################################################################## */
    /**
     The ideal aspect ratio (X / Y) of the display.
     */
    var idealAspect: CGFloat { _ledPathMaker?.idealAspect ?? 1.0 }

    /* ################################################################## */
    /**
     The numerical base of the display (2, 8, 10, 16). 16 is default.
     If you set a different radix from the ones listed, the set will be refused.
     */
    var radix: Int? {
        get { _ledPathMaker?.radix }
        set {
            let oldRadix = _ledPathMaker?.radix ?? 0
            guard let newValue = newValue else { return }
            _ledPathMaker?.radix = newValue
            if oldRadix != newValue {
                setNeedsLayout()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Public Base Class Overrides
/* ###################################################################################################################################### */
public extension RVS_RetroLEDDigitalDisplay {
    /* ################################################################## */
    /**
     This property allows you to assign an image to the off segments.
     If this is set to an image (non-nil), then that will supersede the gradient colors.
     */
    override var image: UIImage? {
        get { super.image }
        set {
            super.image = newValue
            _clearOffColorLayer()
            setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the views are to be laid out. Most of the action happens here.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        if let pathMaker = _ledPathMaker {
            let scaleTransform = CGAffineTransform(scaleX: bounds.size.width / pathMaker.drawingSize.width, y: bounds.size.height / pathMaker.drawingSize.height)
            if let newLayer = _makeOffColorLayer() {
                let shape = CAShapeLayer()
                let path = pathMaker.inactiveSegments
                path.apply(scaleTransform)
                shape.path = path.cgPath
                newLayer.mask = shape
            }
            
            if let newLayer = _makeOnColorLayer() {
                let shape = CAShapeLayer()
                let path = pathMaker.activeSegments
                path.apply(scaleTransform)
                shape.path = path.cgPath
                newLayer.mask = shape
            }
            
            let shape = CAShapeLayer()
            let path = pathMaker.allSegments
            path.apply(scaleTransform)
            shape.path = path.cgPath
            layer.mask = shape
            
            transform = CGAffineTransform(a: 1, b: 0, c: -skew, d: 1, tx: 0, ty: 0)
        }
    }
}
