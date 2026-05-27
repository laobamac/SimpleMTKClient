//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  NSImage+Extensions.swift
//  SimpleMTK
//
//  Created by Bat.bat on 19/6/2024.
//  Copyright © 2024 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Cocoa

extension NSImage {
    @available(macOS 11.0, *)
    public convenience init?(systemSymbolName name: String) {
        self.init(systemSymbolName: name, accessibilityDescription: nil)
    }
}
