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
// MARK: - Private UIImage Extension For Resizing -
/* ###################################################################################################################################### */
fileprivate extension UIImage {
    /* ################################################################## */
    /**
     This allows an image to be resized, given a maximum dimension, and a scale will be determined to meet that dimension.
     If the image is currently smaller than the maximum size, it will not be scaled.
     
     - parameter toMaximumSize: The maximum size, in either the X or Y axis, of the image, in pixels.
     
     - returns: A new image, with the given dimensions. May be nil, if there was an error.
     */
    func _resized(toMaximumSize: CGFloat) -> UIImage? {
        let scaleX: CGFloat = toMaximumSize / size.width
        let scaleY: CGFloat = toMaximumSize / size.height
        return _resized(toScaleFactor: min(1.0, min(scaleX, scaleY)))
    }

    /* ################################################################## */
    /**
     This allows an image to be resized, given a maximum dimension, and a scale will be determined to meet that dimension.
     
     - parameter toScaleFactor: The scale of the resulting image, as a multiplier of the current size.
     
     - returns: A new image, with the given scale. May be nil, if there was an error.
     */
    func _resized(toScaleFactor inScaleFactor: CGFloat) -> UIImage? { _resized(toNewWidth: size.width * inScaleFactor, toNewHeight: size.height * inScaleFactor) }
    
    /* ################################################################## */
    /**
     This allows an image to be resized, given both a width and a height, or just one of the dimensions.
     
     - parameters:
         - toNewWidth: The width (in pixels) of the desired image. If not provided, a scale will be determined from the toNewHeight parameter.
         - toNewHeight: The height (in pixels) of the desired image. If not provided, a scale will be determined from the toNewWidth parameter.
     
     - returns: A new image, with the given dimensions. May be nil, if no width or height was supplied, or if there was an error.
     */
    func _resized(toNewWidth inNewWidth: CGFloat? = nil, toNewHeight inNewHeight: CGFloat? = nil) -> UIImage? {
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
// MARK: - Retro LED Display As An Image View -
/* ###################################################################################################################################### */
/**
 The display is a subclass of UIImageView. We do this, so we can easily have a background image.
 */
open class RVS_RetroLEDDisplay: UIImageView {
    /* ################################################################################################################################## */
    // MARK: Private Stored Properties
    /* ################################################################################################################################## */
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
     This caches the gradient layer. This is set when the gradient is redrawn.
     If this is not-nil, then it will be fetched, instead of redrawing the gradient.
     In order to force the gradient to redraw, set this to nil.
     */
    private var _gradientLayer: CAGradientLayer?

    /* ################################################################## */
    /**
     The starting color for the gradient.
     */
    private var _gradientStartColor: UIColor? {
        didSet {
            _gradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The ending color.
     */
    private var _gradientEndColor: UIColor? {
        didSet {
            _gradientLayer = nil
            setNeedsLayout()
        }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees.
     */
    private var _gradientAngleInDegrees: CGFloat = 0 {
        didSet {
            _gradientLayer = nil
            setNeedsLayout()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Private Computed Properties
/* ###################################################################################################################################### */
private extension RVS_RetroLEDDisplay {
    /* ################################################################## */
    /**
     This returns the background gradient layer, rendering it, if necessary.
     */
    var _fetchGradientLayer: CALayer? { _makeGradientLayer() }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
private extension RVS_RetroLEDDisplay {
    /* ################################################################## */
    /**
     This creates the gradient layer, using our specified start and stop colors.
     If the gradient cache is available, we immediately return that, instead.
     */
    func _makeGradientLayer() -> CALayer? {
        guard nil == _gradientLayer else { return _gradientLayer }
        
        // We try to get whatever the user explicitly set. If not that, then a background color, then the tint color (both ours and super), and, finally, the accent color. If not that, we give up.
        if let startColor = gradientStartColor ?? _originalBackgroundColor ?? _originalTintColor ?? superview?.tintColor ?? UIColor(named: "AccentColor") {
            let endColor = gradientEndColor ?? startColor
            _gradientLayer = CAGradientLayer()
            _gradientLayer?.frame = bounds
            _gradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
            _gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: gradientAngleInDegrees)
            _gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)._rotated(around: CGPoint(x: 0.5, y: 0.5), byDegrees: gradientAngleInDegrees)
        } else {
            assertionFailure("No Starting Color Provided for the RVS_MaskButton class!")
        }
        
        return _gradientLayer
    }
}

/* ###################################################################################################################################### */
// MARK: Public Computed Properties
/* ###################################################################################################################################### */
public extension RVS_RetroLEDDisplay {
    /* ################################################################## */
    /**
     The starting color for the gradient.
     If not provided, the view backgroundColor is used.
     If that is not provided, then the view tintColor is used.
     If that is not provided, then the super (parent) view tintColor is used.
     If that is not provided, the AccentColor is used.
     If that is not provided, the class will not work.
     */
    @IBInspectable var gradientStartColor: UIColor? {
        get { _gradientStartColor }
        set { _gradientStartColor = newValue }
    }

    /* ################################################################## */
    /**
     The ending color. If not provided, then the starting color is used.
     */
    @IBInspectable var gradientEndColor: UIColor? {
        get { _gradientEndColor }
        set { _gradientEndColor = newValue }
    }

    /* ################################################################## */
    /**
     The angle of the gradient, in degrees. 0 (default) is top-to-bottom.
     Zero is top-to-bottom.
     Negative is counter-clockwise, and positive is clockwise.
     */
    @IBInspectable var gradientAngleInDegrees: CGFloat {
        get { _gradientAngleInDegrees }
        set { _gradientAngleInDegrees = newValue }
    }
}
