//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  AppDelegate.swift
//  SimpleMTK
//
//  Created by 梁怀宇 on 2020/3/20.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        checkRunPath()
        checkAPI()

        let statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let legacyUIEnabled = {
            if #unavailable(macOS 11) {
                return true
            }
            return UserDefaults.standard.bool(forKey: .DefaultsKey.legacyUI)
        }()

        Log.debug("UI appearance: \(legacyUIEnabled ? "legacy" : "modern")")

        let iconProvider: StatusBarIconProvider = {
            if #available(macOS 11, *), !legacyUIEnabled {
                return StatusBarIconModern()
            }
            return StatusBarIconLegacy()
        }()
        _ = StatusBarIcon.shared(statusBar: statusBar, icons: iconProvider)

        if #available(macOS 11, *), !legacyUIEnabled {
            statusBar.menu = StatusMenuModern()
        } else {
            statusBar.menu = StatusMenuLegacy()
        }
    }

    private var drv_info = ioctl_driver_info()

    private func checkDriver() -> Bool {

        _ = ioctl_get(Int32(IOCTL_80211_DRIVER_INFO.rawValue), &drv_info, MemoryLayout<ioctl_driver_info>.size)

        let version = String(cCharArray: drv_info.driver_version)
        let interface = String(cCharArray: drv_info.bsd_name)
        guard !version.isEmpty, !interface.isEmpty else {
            Log.error("SimpleMtkWlan kext not loaded!")
#if !DEBUG
            let alert = CriticalAlert(message: NSLocalizedString("SimpleMtkWlan is not running"),
                                      options: [NSLocalizedString("Dismiss"),
                                                NSLocalizedString("Quit SimpleMTK")])

            if alert.show() == .alertSecondButtonReturn {
                NSApp.terminate(nil)
            }

#endif
            return false
        }

        Log.debug("Loaded SimpleMtkWlan \(version) as \(interface)")

        return true
    }

    private func checkRunPath() {
        let bundlePath = URL(fileURLWithPath: Bundle.main.bundlePath).standardizedFileURL.path

#if DEBUG
        Log.debug("Running from \(bundlePath)")
#else
        // App Translocation or non-standard install paths can break Sparkle and
        // launch-at-login, but they should not prevent the status app from opening.
        if bundlePath.contains("/AppTranslocation/") {
            Log.error("Running from App Translocation path: \(bundlePath)")
        } else if !bundlePath.hasPrefix("/Applications/") &&
                    !bundlePath.hasPrefix("\(NSHomeDirectory())/Applications/") {
            Log.debug("Running outside Applications: \(bundlePath)")
        }
#endif
    }

    private func checkAPI() {

        // It's fine for users to bypass this check by launching SimpleMTK first then loading SimpleMtkWlan in terminal
        // Only advanced users do so, and they know what they are doing
        guard checkDriver(), IOCTL_VERSION != drv_info.version else {
            return
        }

        Log.error("SimpleMtkWlan API mismatch!")

#if !DEBUG
        let text = NSLocalizedString("SimpleMTK API Version: ") + String(IOCTL_VERSION) +
                   "\n" + NSLocalizedString("SimpleMtkWlan API Version: ") + String(drv_info.version)
        let alert = CriticalAlert(message: NSLocalizedString("SimpleMtkWlan Version Mismatch"),
                                  informativeText: text,
                                  options: [NSLocalizedString("Quit SimpleMTK"),
                                            NSLocalizedString("Visit SimpleMTKClient on GitHub")]
        )

        if alert.show() == .alertSecondButtonReturn {
            NSWorkspace.shared.open(URL(string: "https://github.com/laobamac/SimpleMTKClient")!)
            return
        }

        NSApp.terminate(nil)
#endif
    }

    func applicationWillTerminate(_ notification: Notification) {
        Log.debug("Exit")
        api_terminate()
    }
}
