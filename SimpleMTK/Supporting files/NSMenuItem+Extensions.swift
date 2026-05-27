//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  NSMenuItem+Extensions.swift
//  SimpleMTK
//
//  Created by Igor Kulman on 29/06/2020.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Foundation
import Cocoa

extension NSMenuItem {
    enum ItemHeight: CGFloat {
        case textLegacy = 19
        case textModern = 22
        case networkModern = 32
    }

    convenience init(title: String) {
        self.init(title: title, action: nil, keyEquivalent: "")
    }

    convenience init(title: String, action: Selector) {
        self.init(title: title, action: action, keyEquivalent: "")
    }
}
