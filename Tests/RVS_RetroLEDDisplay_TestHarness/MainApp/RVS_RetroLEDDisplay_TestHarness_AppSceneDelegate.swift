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

/* ###################################################################################################################################### */
// MARK: - Main App/Scene Delegate -
/* ###################################################################################################################################### */
/**
 This is a simple application delegate that allows the app to start up.
 */
@main
class RVS_RetroLEDDisplay_TestHarness_AppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     The name of our default configuration.
     */
    private static let _configurationName = "Default Configuration"
    
    /* ################################################################## */
    /**
     The required window instance.
     */
    var window: UIWindow?
}

/* ###################################################################################################################################### */
// MARK: UIApplicationDelegate Conformance
/* ###################################################################################################################################### */
extension RVS_RetroLEDDisplay_TestHarness_AppSceneDelegate: UIApplicationDelegate {
    /* ################################################################## */
    /**
     Called when the application has completed startup, and is ready to go.
     
     - parameters: ignored
     - returns: True (always).
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    /* ################################################################## */
    /**
     Called when querying for a scene config.
     
     - parameter: The application instance (ignored).
     - parameter configurationForConnecting: The scene session that requires configuration. We fetch the role from it.
     - parameter options: Ignored
     
     - returns: The default configuration (always).
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: Self._configurationName, sessionRole: inConnectingSceneSession.role)
    }
}
