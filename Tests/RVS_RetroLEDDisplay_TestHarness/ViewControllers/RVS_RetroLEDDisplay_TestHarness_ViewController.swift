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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - UIView Extension -
/* ###################################################################################################################################### */
extension UIView {
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
// MARK: - UIColor Extension For Inverting Colors -
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
// MARK: - Main Screen View Controller For Tab 0 -
/* ###################################################################################################################################### */
/**
 The View Controller for the test screen.
 */
class RVS_RetroLEDDisplay_TestHarness_ViewController: UIViewController {
    /* ################################################################################################################################## */
    // MARK: Aspect Switch Index Definitions
    /* ################################################################################################################################## */
    /**
     This defines the aspect switch selections.
     */
    enum AspectSwitchIndexes: Int {
        /// This rotates the normal aspect.
        case rotated
        
        /// This has a square (equal sides) aspect.
        case square
        
        /// "Normal" means that the LED set is queried for the "ideal" aspect, and that is used.
        case normal
    }
    
    /* ################################################################################################################################## */
    // MARK: Fill Switch Index Definitions
    /* ################################################################################################################################## */
    /**
     This defines the two fill switch selections.
     */
    enum FillSwitchIndexes: Int {
        /// This uses images, but they are simple color fills.
        case initial
        
        /// This uses images of a paisley pattern
        case ugly
        
        /// This uses preset gradients.
        case gradients
        
        /// This uses solid (non-gradient) colors, with the "off" selection being clear.
        case solid
    }
    
    /* ################################################################## */
    /**
     The name for the image we use for the solid-color-fill On image.
    */
    static private let _defaultOnImageName = "OnImage"
    
    /* ################################################################## */
    /**
     The name for the image we use for the solid-color-fill Off image.
    */
    static private let _defaultOffImageName = "OffImage"
    
    /* ################################################################## */
    /**
     The name for the image we use for the paisley On image.
    */
    static private let _uglyOnImageName = "Pattern1"
    
    /* ################################################################## */
    /**
     The name for the image we use for the paisley Off image.
    */
    static private let _uglyOffImageName = "Pattern0"
    
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

    /* ################################################################## */
    /**
     This constraint is used to set the aspect ratio of the code under test.
    */
    weak var aspectConstraint: NSLayoutConstraint?

    /* ################################################################## */
    /**
     This is the instance of a triple "LED" digit to be tested.
    */
    @IBOutlet weak var testTargetImage: RVS_RetroLEDDigitalDisplay?
    
    /* ################################################################## */
    /**
     This slider controls the actual numerical value, displayed by the code under test.
    */
    @IBOutlet weak var valueSlider: UISlider?
    
    /* ################################################################## */
    /**
     This switches between three different aspect ratios for the code under test.
    */
    @IBOutlet weak var aspectSegmentedSwitch: UISegmentedControl?
    
    /* ################################################################## */
    /**
     This controls the fill for the "on" segments.
    */
    @IBOutlet weak var onFillSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     This controls the angle of both gradients. It will only be enabled, if one of the segmented switches is (or both are) set to "gradient."
    */
    @IBOutlet weak var gradientAngleSlider: UISlider?

    /* ################################################################## */
    /**
     This controls the fill for the "off" segments.
    */
    @IBOutlet weak var offFillSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     This is a precision stepper, for changing the value in small increments/decrements.
    */
    @IBOutlet weak var stepper: UIStepper?

    /* ################################################################## */
    /**
     This changes the base for the numbers displayed by the code under test.
    */
    @IBOutlet weak var radixSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     This changes the skew of the code under test.
    */
    @IBOutlet weak var skewSlider: UISlider?

    /* ################################################################## */
    /**
     This allows us to change the number of digits, displayed by the code under test.
    */
    @IBOutlet weak var numberOfDigitsSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var leadingZeroesLabelButton: UIButton?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var leadingZeroesSwitch: UISwitch?
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_ViewController {
    /* ################################################################## */
    /**
     This determines whether or not the gradient angle switch is enabled.
     In order for it to be enabled, at least one of the fill switches needs to be set to "gradient."
    */
    func determineGradientSliderEnabledState() {
        if let onFillSegmentedSwitch = onFillSegmentedSwitch,
           let offFillSegmentedSwitch = offFillSegmentedSwitch,
           let gradientAngleSlider = gradientAngleSlider {
            gradientAngleSlider.isEnabled = (onFillSegmentedSwitch.selectedSegmentIndex == FillSwitchIndexes.gradients.rawValue)
                                            || (offFillSegmentedSwitch.selectedSegmentIndex == FillSwitchIndexes.gradients.rawValue)
            if !gradientAngleSlider.isEnabled {
                gradientAngleSlider.value = 0
            }
            gradientAngleSlider.setNeedsLayout()
            gradientAngleSliderChanged(gradientAngleSlider) // When it is disabled, we will set it back to 0.
        }
    }
    
    /* ################################################################## */
    /**
     This clears the value, and resets it to the midpoint.
    */
    func resetValue() {
        if let min = testTargetImage?.minValue,
           let max = testTargetImage?.maxValue,
           let aspectSegmentedSwitch = aspectSegmentedSwitch {
            valueSlider?.minimumValue = Float(min)
            valueSlider?.maximumValue = Float(max)
            valueSlider?.value = round(Float(max) / 2)
            testTargetImage?.value = Int(round(Float(max) / 2))
            aspectSegmentedSwitchChanged(aspectSegmentedSwitch)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_ViewController {
    /* ################################################################## */
    /**
     Called after the view hierarchy is loaded.
     We use this to set everything up, and apply localizations.
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

        if let aspectSegmentedSwitch = aspectSegmentedSwitch {
            for index in 0..<aspectSegmentedSwitch.numberOfSegments {
                aspectSegmentedSwitch.setTitle((aspectSegmentedSwitch.titleForSegment(at: index) ?? "ERROR").localizedVariant, forSegmentAt: index)
            }
            
            aspectSegmentedSwitchChanged(aspectSegmentedSwitch)
        }
        
        if let fillSegmentedSwitch = onFillSegmentedSwitch {
            for index in 0..<fillSegmentedSwitch.numberOfSegments {
                fillSegmentedSwitch.setTitle((fillSegmentedSwitch.titleForSegment(at: index) ?? "ERROR").localizedVariant, forSegmentAt: index)
            }
            
            onFillSegmentedSwitchChanged(fillSegmentedSwitch)
        }
        
        if let fillSegmentedSwitch = offFillSegmentedSwitch {
            for index in 0..<fillSegmentedSwitch.numberOfSegments {
                fillSegmentedSwitch.setTitle((fillSegmentedSwitch.titleForSegment(at: index) ?? "ERROR").localizedVariant, forSegmentAt: index)
            }
            
            offFillSegmentedSwitchChanged(fillSegmentedSwitch)
        }
        
        if let numberOfDigitsSegmentedSwitch = numberOfDigitsSegmentedSwitch {
            numberOfDigitsSegmentedSwitchChanged(numberOfDigitsSegmentedSwitch)
        }
        
        if let radixSegmentedSwitch = radixSegmentedSwitch {
            radixSegmentedSwitchChanged(radixSegmentedSwitch)
        }
        
        leadingZeroesLabelButton?.setTitle("SLUG-LEADING-ZEROES".localizedVariant, for: .normal)
        determineGradientSliderEnabledState()
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_ViewController {
    /* ################################################################## */
    /**
     Called when the aspect segmented control has changed.
     - parameter inSegmentedControl: The segmented switch that changed.
    */
    @IBAction func aspectSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        if let idealAspect = testTargetImage?.idealAspect {
            aspectConstraint?.isActive = false
            
            switch inSegmentedControl.selectedSegmentIndex {
            case AspectSwitchIndexes.rotated.rawValue:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: idealAspect)

            case AspectSwitchIndexes.square.rawValue:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: 1)

            case AspectSwitchIndexes.normal.rawValue:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: 1 / idealAspect)

            default:
                break
            }
            
            aspectConstraint?.isActive = true
            
            if let skewSlider = skewSlider {
                skewSlider.value = 0
                skewSliderChanged(skewSlider)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the on fill segmented control has changed.
     - parameter inSegmentedControl: The segmented switch that changed.
    */
    @IBAction func onFillSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        switch inSegmentedControl.selectedSegmentIndex {
        case FillSwitchIndexes.initial.rawValue:
            testTargetImage?.onImage = UIImage(named: Self._defaultOnImageName)

        case FillSwitchIndexes.ugly.rawValue:
            testTargetImage?.onImage = UIImage(named: Self._uglyOnImageName)

        case FillSwitchIndexes.gradients.rawValue:
            testTargetImage?.onImage = nil
            testTargetImage?.onGradientStartColor = UIColor(named: "GradientOnTopColor")
            testTargetImage?.onGradientEndColor = UIColor(named: "GradientOnBottomColor")

        case FillSwitchIndexes.solid.rawValue:
            testTargetImage?.onImage = nil
            testTargetImage?.onGradientStartColor = .label.inverted
            testTargetImage?.onGradientEndColor = nil

        default:
            break
        }
        
        determineGradientSliderEnabledState()
    }
    
    /* ################################################################## */
    /**
     Called when the off fill segmented control has changed.
     - parameter inSegmentedControl: The segmented switch that changed.
    */
    @IBAction func offFillSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        switch inSegmentedControl.selectedSegmentIndex {
        case FillSwitchIndexes.initial.rawValue:
            testTargetImage?.image = UIImage(named: Self._defaultOffImageName)

        case FillSwitchIndexes.ugly.rawValue:
            testTargetImage?.image = UIImage(named: Self._uglyOffImageName)

        case FillSwitchIndexes.gradients.rawValue:
            testTargetImage?.image = nil
            testTargetImage?.offGradientStartColor = UIColor(named: "GradientOffTopColor")
            testTargetImage?.offGradientEndColor = UIColor(named: "GradientOffBottomColor")

        case FillSwitchIndexes.solid.rawValue:
            testTargetImage?.image = nil
            testTargetImage?.offGradientStartColor = .clear
            testTargetImage?.offGradientEndColor = nil

        default:
            break
        }
        
        determineGradientSliderEnabledState()
    }
    
    /* ################################################################## */
    /**
     Called when the radix (number base) switch has changed
     - parameter inSegmentedControl: The segmented switch that changed.
    */
    @IBAction func radixSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        guard let newRadix = Int(inSegmentedControl.titleForSegment(at: inSegmentedControl.selectedSegmentIndex) ?? "") else { return }
        testTargetImage?.radix = newRadix
        if let valueSlider = valueSlider,
           let aspectSegmentedSwitch = aspectSegmentedSwitch,
           let min = testTargetImage?.minValue,
           let max = testTargetImage?.maxValue {
            let value = Int(round(Float(max) / 2))
            valueSlider.minimumValue = Float(min)
            valueSlider.maximumValue = Float(max)
            valueSlider.value = Float(value)
            testTargetImage?.value = value
            aspectSegmentedSwitchChanged(aspectSegmentedSwitch)
        }
    }

    /* ################################################################## */
    /**
     The number of digits has changed.
     - parameter inSegmentedControl: The segmented control that changed.
    */
    @IBAction func numberOfDigitsSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        guard let newValue = Int(inSegmentedControl.titleForSegment(at: inSegmentedControl.selectedSegmentIndex) ?? "") else { return }
        testTargetImage?.numberOfDigits = newValue
        if let radixSegmentedSwitch = radixSegmentedSwitch,
           let aspectSegmentedSwitch = aspectSegmentedSwitch,
           let radix = Int(radixSegmentedSwitch.titleForSegment(at: radixSegmentedSwitch.selectedSegmentIndex) ?? "") {
            testTargetImage?.radix = radix
            if let valueSlider = valueSlider,
               let min = testTargetImage?.minValue,
               let max = testTargetImage?.maxValue {
                let value = Int(round(Float(max) / 2))
                valueSlider.minimumValue = Float(min)
                valueSlider.maximumValue = Float(max)
                valueSlider.value = Float(value)
                testTargetImage?.value = value
                valueSliderChanged(valueSlider)
            }
            
            aspectSegmentedSwitchChanged(aspectSegmentedSwitch)
        }
    }

    /* ################################################################## */
    /**
     Called when the value has changed.
     - parameter inSlider: The slider instance.
    */
    @IBAction func valueSliderChanged(_ inSlider: UISlider) {
        let intValue = Int(inSlider.value)
        testTargetImage?.value = intValue
        inSlider.value = Float(intValue)
    }
    
    /* ################################################################## */
    /**
     Called when the skew slider has changed.
     - parameter inSlider: The slider instance.
    */
    @IBAction func skewSliderChanged(_ inSlider: UISlider) {
        testTargetImage?.skew = CGFloat(inSlider.value)
    }
    
    /* ################################################################## */
    /**
     Called when the gradient angle slider has changed.
     - parameter inSlider: The slider instance.
    */
    @IBAction func gradientAngleSliderChanged(_ inSlider: UISlider) {
        testTargetImage?.onGradientAngleInDegrees = CGFloat(inSlider.value)
        testTargetImage?.offGradientAngleInDegrees = CGFloat(inSlider.value)
    }

    /* ################################################################## */
    /**
     Called when the incremental value stepper has changed.
     - parameter inStepper: The stepper that changed.
    */
    @IBAction func stepperHit(_ inStepper: UIStepper) {
        if let valueSlider = valueSlider {
            valueSlider.value += Float(inStepper.value)
            inStepper.value = 0
            valueSliderChanged(valueSlider)
        }
    }

    /* ################################################################## */
    /**
     This is called, whenever either the "label" of the switch, or the switch, itself,
     is hit.
     
     - parameter inSwitchOrButton: Either the switch, or the button we use as a label.
    */
    @IBAction func leadingZeroesHit(_ inSwitchOrButton: UIControl) {
        if inSwitchOrButton is UIButton {
            leadingZeroesSwitch?.setOn(!(leadingZeroesSwitch?.isOn ?? true), animated: true)
            leadingZeroesSwitch?.sendActions(for: .valueChanged)
        } else if let leadingZeroes = inSwitchOrButton as? UISwitch {
            testTargetImage?.hasLeadingZeroes = leadingZeroes.isOn
        }
    }
}
