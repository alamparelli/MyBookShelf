//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
    }
    static var version: String {
        return "\(release).\(build)"
    }
}

//
//Text("release: \(UIApplication.release)")
//Text("build: \(UIApplication.build)")
//Text("version: \(UIApplication.version)")
