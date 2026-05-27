//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  mtk_80211_state+Extensions.swift
//  SimpleMTK
//
//  Created by Igor Kulman on 30/06/2020.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Foundation

extension mtk_80211_state: CustomStringConvertible, Comparable {
    public var description: String {
        switch self {
        case MTK80211_S_INIT:
            return "Wi-Fi: On"
        case MTK80211_S_SCAN:
            return "Wi-Fi: Looking for Networks..."
        case MTK80211_S_AUTH, MTK80211_S_ASSOC:
            return "Wi-Fi: Connecting"
        case MTK80211_S_RUN:
            return "Wi-Fi: Connected"
        default:
            return "Wi-Fi: Status unavailable"
        }
    }

    public static func < (lhs: mtk_80211_state, rhs: mtk_80211_state) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
