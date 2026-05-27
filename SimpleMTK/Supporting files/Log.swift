//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  Log.swift
//  SimpleMTK
//
//  Created by Igor Kulman on 22/06/2020.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Foundation
import os.log

final class Log {
    static func debug(_ message: String) {
        if #available(OSX 11.0, *) {
            Logger.simpleMTK.info("DEBUG: \(message, privacy: .public)")
        } else {
            os_log("%{public}@", log: .simpleMTK, type: .info, "DEBUG: " + message)
        }
    }

    static func error(_ message: String) {
        if #available(OSX 11.0, *) {
            Logger.simpleMTK.error("ERROR: \(message, privacy: .public)")
        } else {
            os_log("%{public}@", log: .simpleMTK, type: .error, "ERROR: " + message)
        }
    }
}

@available(OSX 11.0, *)
extension Logger {
    static let simpleMTK = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleMTK")
}

extension OSLog {
    static let simpleMTK = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SimpleMTK")
}
