//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  UpdateManager.swift
//  SimpleMTK
//
//  Created by Bat.bat on 1/8/2024.
//  Copyright © 2024 OpenIntelWireless. All rights reserved.
//

import Foundation
import Sparkle

final class UpdateManager {
    public static let sharedController = SPUStandardUpdaterController(startingUpdater: true,
                                                                      updaterDelegate: nil,
                                                                      userDriverDelegate: nil)

    public static var sharedUpdater: SPUUpdater { return sharedController.updater }

    private init() {}
}
