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
// MARK: - Main Screen View Controller For Tab 0 -
/* ###################################################################################################################################### */
/**
 The View Controller for the Tab 0 (Basic) screen.
 */
class RVS_RetroLEDDisplay_TestHarness_Tab0_ViewController: RVS_RetroLEDDisplay_TestHarness_BaseViewController {
    /* ################################################################## */
    /**
     This is the instance of a triple "LED" digit to be tested.
    */
    @IBOutlet weak var testTargetImage: RVS_RetroLEDDigitalDisplay?
    
    /* ################################################################## */
    /**
    */
    @IBOutlet weak var valueSlider: UISlider?
    
    /* ################################################################## */
    /**
    */
    @IBOutlet weak var aspectSegmentedSwitch: UISegmentedControl?
    
    /* ################################################################## */
    /**
    */
    @IBOutlet weak var fillSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
    */
    @IBOutlet weak var stepper: UIStepper!

    /* ################################################################## */
    /**
    */
    weak var aspectConstraint: NSLayoutConstraint?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_Tab0_ViewController {
    /* ################################################################## */
    /**
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aspectSegmentedSwitch = aspectSegmentedSwitch {
            for index in 0..<aspectSegmentedSwitch.numberOfSegments {
                aspectSegmentedSwitch.setTitle((aspectSegmentedSwitch.titleForSegment(at: index) ?? "ERROR").localizedVariant, forSegmentAt: index)
            }
            
            aspectSegmentedSwitchChanged(aspectSegmentedSwitch)
        }
        
        if let fillSegmentedSwitch = fillSegmentedSwitch {
            for index in 0..<fillSegmentedSwitch.numberOfSegments {
                fillSegmentedSwitch.setTitle((fillSegmentedSwitch.titleForSegment(at: index) ?? "ERROR").localizedVariant, forSegmentAt: index)
            }
            
            fillSegmentedSwitchChanged(fillSegmentedSwitch)
        }
        
        if let min = testTargetImage?.minValue,
           let max = testTargetImage?.maxValue {
            valueSlider?.minimumValue = Float(min)
            valueSlider?.maximumValue = Float(max)
            valueSlider?.value = round(Float(max) / 2)
            testTargetImage?.value = Int(round(Float(max) / 2))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_Tab0_ViewController {
    /* ################################################################## */
    /**
    */
    @IBAction func valueSliderChanged(_ inSlider: UISlider) {
        let intValue = Int(inSlider.value)
        testTargetImage?.value = intValue
        inSlider.value = Float(intValue)
    }
    
    /* ################################################################## */
    /**
    */
    @IBAction func aspectSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
        if let idealAspect = testTargetImage?.idealAspect {
            aspectConstraint?.isActive = false
            
            switch inSegmentedControl.selectedSegmentIndex {
            case 0:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: idealAspect)

            case 1:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: 1)

            case 2:
                aspectConstraint = testTargetImage?.autoLayoutAspectConstraint(aspectRatio: 1 / idealAspect)

            default:
                break
            }
            
            aspectConstraint?.isActive = true
        }
    }
    
    /* ################################################################## */
    /**
    */
    @IBAction func fillSegmentedSwitchChanged(_ inSegmentedControl: UISegmentedControl) {
    }
    
    /* ################################################################## */
    /**
    */
    @IBAction func stepperHit(_ inStepper: UIStepper) {
        if let valueSlider = valueSlider {
            valueSlider.value += Float(inStepper.value)
            inStepper.value = 0
            valueSliderChanged(valueSlider)
        }
    }
}
