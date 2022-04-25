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
*/

import UIKit
import RVS_RetroLEDDisplay

/* ###################################################################################################################################### */
// MARK: - Private UIColor Extension For Inverting Colors -
/* ###################################################################################################################################### */
extension UIColor {
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
// MARK: - UIView Extension -
/* ###################################################################################################################################### */
/**
 We add a couple of ways to deal with first responders.
 */
extension UIView {
    /* ################################################################## */
    /**
     This allows us to add a subview, and set it up with auto-layout constraints to fill the superview.
     
     - parameter inSubview: The subview we want to add.
     - parameter underThis: If supplied, this is a Y-axis anchor to use as the attachment of the top anchor.
                            Default is nil (can be omitted, which will simply attach to the top of the container).
     - parameter andGiveMeABottomHook: If this is true, then the bottom anchor of the subview will not be attached to anything, and will simply be returned.
                                       Default is false, which means that the bottom anchor will simply be attached to the bottom of the view.
     - returns: The bottom hook, if requested. Can be ignored.
     */
    @discardableResult
    func addContainedView(_ inSubView: UIView, underThis inUpperConstraint: NSLayoutYAxisAnchor? = nil, andGiveMeABottomHook inBottomLoose: Bool = false) -> NSLayoutYAxisAnchor? {
        addSubview(inSubView)
        
        inSubView.translatesAutoresizingMaskIntoConstraints = false
        if let underConstraint = inUpperConstraint {
            inSubView.topAnchor.constraint(equalTo: underConstraint, constant: 0).isActive = true
        } else {
            inSubView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        }
        inSubView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        inSubView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        
        if inBottomLoose {
            return inSubView.bottomAnchor
        } else {
            inSubView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     This creates a constraint, locking the view to a given aspect ratio.
     - parameter aspectRatio: The aspect ratio. It is W/H, so numbers less than 1.0 are wider than tall, and numbers greater than 1.0 are taller than wide.
     - returns: An inactive constraint, locking this view to the given aspect ratio.
     */
    func autoLayoutAspectConstraint(aspectRatio inAspect: CGFloat) -> NSLayoutConstraint? {
        guard 0.0 < inAspect else { return nil }
        
        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: inAspect, constant: 0)
    }
}

/* ###################################################################################################################################### */
// MARK: - Main Screen View Controller -
/* ###################################################################################################################################### */
/**
 A baseline view controller for all displayed screens.
 */
class RVS_RetroLEDDisplay_TestHarness_BaseViewController: UIViewController {
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    var backgroundGradientImage: UIImage? = UIImage(named: "background-gradient")
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a "watermark."
     */
    var watermarkImage: UIImage? = UIImage(named: "CentralWatermark")

    /* ################################################################## */
    /**
     This is the background image view.
     */
    var myBackgroundGradientView: UIImageView?

    /* ################################################################## */
    /**
     This is the background center image view.
     */
    var myCenterImageView: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_BaseViewController {
    /* ################################################################## */
    /**
     Called after the hierarchy was loaded. We use this to set up our background.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = view {
            myBackgroundGradientView = UIImageView()
            if let backgroundGradientView = myBackgroundGradientView,
               let backGroundImage = backgroundGradientImage {
                backgroundGradientView.image = backGroundImage
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.contentMode = .scaleToFill
                view.insertSubview(backgroundGradientView, at: 0)
                
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                myCenterImageView = UIImageView()
                if let centerImageView = myCenterImageView,
                   let centerImage = watermarkImage {
                    centerImageView.image = centerImage
                    centerImageView.alpha = 0.05
                    centerImageView.translatesAutoresizingMaskIntoConstraints = false
                    centerImageView.contentMode = .scaleAspectFit
                    backgroundGradientView.insertSubview(centerImageView, at: 1)

                    centerImageView.centerXAnchor.constraint(equalTo: backgroundGradientView.centerXAnchor).isActive = true
                    centerImageView.centerYAnchor.constraint(equalTo: backgroundGradientView.centerYAnchor).isActive = true
                    
                    centerImageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.widthAnchor, multiplier: 0.6).isActive = true
                    centerImageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.heightAnchor, multiplier: 0.6).isActive = true

                    if let aspectConstraint = centerImageView.autoLayoutAspectConstraint(aspectRatio: 1.0) {
                        aspectConstraint.isActive = true
                        backgroundGradientView.addConstraint(aspectConstraint)
                    }
                }
            }
        }
    }
}
