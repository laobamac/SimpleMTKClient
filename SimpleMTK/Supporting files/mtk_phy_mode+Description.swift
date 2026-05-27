//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  mtk_phy_mode+Description.swift
//  SimpleMTK
//
//  Created by Igor Kulman on 07/07/2020.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Foundation

extension mtk_phy_mode: CustomStringConvertible {
    public var description: String {
        switch self {
        case MTK80211_MODE_11A:
            return "802.11a"
        case MTK80211_MODE_11B:
            return "802.11b"
        case MTK80211_MODE_11G:
            return "802.11g"
        case MTK80211_MODE_11N:
            return "802.11n"
        case MTK80211_MODE_11AC:
            return "802.11ac"
        case MTK80211_MODE_11AX:
            return "802.11ax"
        default:
            return "Unknown"
        }
    }
}
