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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Main Tab Bar Controller -
/* ###################################################################################################################################### */
/**
 This handles the tab bar controller, and deals with display customization.
 */
class RVS_RetroLEDDisplay_TestHarness_TabBarController: UITabBarController {
    /* ################################################################## */
    /**
     Called when the view hierarchy load has been completed.
     We use this to set the tab bar colors, and select the last selected tab.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let normalColor = UIColor(named: "AccentColor") {
            let selectedColor = UIColor.white

            let normalTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: normalColor]
            let selectedTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: selectedColor]

            let appearance = UITabBarAppearance()
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.inlineLayoutAppearance.normal.iconColor = normalColor
            appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
            appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.compactInlineLayoutAppearance.normal.iconColor = normalColor
            appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
            appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.backgroundColor = .clear

            tabBar.standardAppearance = appearance
            tabBar.itemPositioning = .centered
            tabBar.backgroundColor = .clear
            tabBar.barTintColor = .clear
        }
        
        viewControllers?.forEach {
            if let tabBarItemTitle = $0.tabBarItem?.title?.localizedVariant,
               !tabBarItemTitle.isEmpty {
                $0.tabBarItem?.title = tabBarItemTitle
            }
        }
    }
}
