//
//  SimpleMTK
//
//  Created by laobamac on 2026/5/27.
//  Copyright © 2026 laobamac. All rights reserved.
//

//
//  BugReporter.swift
//  SimpleMTK
//
//  Created by Erik Bautista on 7/26/20.
//  Copyright © 2020 OpenIntelWireless. All rights reserved.
//

/*
 * This program and the accompanying materials are licensed and made available
 * under the terms and conditions of the The 3-Clause BSD License
 * which accompanies this distribution. The full text of the license may be found at
 * https://opensource.org/licenses/BSD-3-Clause
 */

import Cocoa
import OSLog
import IOKit

class BugReporter {

    private static let openPanel: NSOpenPanel = {
        let openPanel = NSOpenPanel()

        openPanel.title = NSLocalizedString("Choose a folder to output the bug report")
        openPanel.message = NSLocalizedString("The bug report will be generated in the seleted folder")
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true

        NSApplication.shared.activate(ignoringOtherApps: true)

        return openPanel
    }()

    private class func generateSimpleMTKLog() -> String {

        // MARK: SimpleMTK log

        let appIdentifier = Bundle.main.bundleIdentifier!

        if #available(OSX 10.15, *) {
            do {
                let logStore = try OSLogStore.local()
                let lastBoot = logStore.position(timeIntervalSinceLatestBoot: 0)
                let matchingPredicate = NSPredicate(format: "subsystem == '\(appIdentifier)'")
                let enumerator = try logStore.getEntries(with: [],
                                                         at: lastBoot,
                                                         matching: matchingPredicate)
                let allEntries = Array(enumerator)
                let osLogEntryLogObjects = allEntries.compactMap { $0 as? OSLogEntryLog }
                var entryStr = ""
                for item in osLogEntryLogObjects where item.subsystem == appIdentifier {
                    entryStr += "\n\(item.date);    \(item.subsystem);    \(item.category);    \(item.composedMessage)"
                }
                return entryStr
            } catch {
                Log.error("Could not generate bug report \(error)")
                return .simpleMTKCouldNotGetLogs
            }
        } else {
            let appLogCommand = ["show", "--predicate",
                                      "(subsystem == '\(appIdentifier)')", "--info", "--last", "boot"]
            let appLog = Commands.execute(executablePath: .log, args: appLogCommand)
            if let stringVal = appLog.0, appLog.1 == 0 {
                return stringVal
            } else {
                return .scriptFailed
            }
        }
    }

    private class func generateSimpleMtkWlanLog() -> String {
        var response: String?

        if KextInfo("as.lvs1974.DebugEnhancer").kextDidLoad() {
            // msgbuf size is sufficient, collect dmesg logs
            response = NSAppleScript(source:
                                     // swiftlint:disable line_length
                                     """
                                     do shell script \"sudo dmesg | grep -E \\"SimpleMtkWlan|Airport|IO80211|EAPOL\\"\" with administrator privileges
                                     """)!.executeAndReturnError(nil).stringValue
                                     // swiftlint:enable line_length
        } else {
            response = .msgbufInsufficient
        }

        return response ?? .scriptFailed
    }

    public class func generateBugReport() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown"
        let appBuildVer = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "Unknown"

        let appLog = generateSimpleMTKLog()

        if appLog == .simpleMTKCouldNotGetLogs || appLog == .scriptFailed {
            DispatchQueue.main.async {
                let alert = CriticalAlert(
                    message: NSLocalizedString("Error occurred while generating bug report."),
                    informativeText: appLog == .simpleMTKCouldNotGetLogs ?
                    NSLocalizedString("Could not generate report for SimpleMTK.") :
                    NSLocalizedString("Command failed to fetch logs for SimpleMTK."),
                    options: [NSLocalizedString("Dismiss")],
                    errorText: appLog
                )
                alert.show()
            }
            return
        }

        // MARK: SimpleMtkWlan log

        var drv_info = ioctl_driver_info()
        _ = ioctl_get(Int32(IOCTL_80211_DRIVER_INFO.rawValue), &drv_info, MemoryLayout<ioctl_driver_info>.size)
        var driverVersion = String(cCharArray: drv_info.driver_version)
        var firmwareVersion = String(cCharArray: drv_info.fw_version)
        if driverVersion.isEmpty { driverVersion = "Unknown" }
        if firmwareVersion.isEmpty { firmwareVersion = "Unknown" }

        let driverLog = generateSimpleMtkWlanLog()

        if driverLog == .msgbufInsufficient || driverLog == .scriptFailed {
            DispatchQueue.main.async {
                let alert = CriticalAlert(
                    message: NSLocalizedString("Error occurred while generating bug report."),
                    informativeText: driverLog == .msgbufInsufficient ?
                    NSLocalizedString("Make sure you have installed `DebugEnhancer.kext`" +
                                      " before collecting logs for SimpleMtkWlan.") :
                    NSLocalizedString("Could not read logs for `SimpleMtkWlan`." +
                                      " Make sure you allow `SimpleMTK` to read logs when prompted."),
                    options: [NSLocalizedString("Dismiss"), NSLocalizedString("Open Documentation")],
                    helpAnchor: .dmesgHelpURL,
                    errorText: driverLog
                )

                if alert.show() == .alertSecondButtonReturn {
                    NSWorkspace.shared.open(URL(string: .dmesgHelpURL)!)
                }
            }
            return
        }

        // MARK: Get SimpleMtkWlan name if loaded (SimpleMtkWlan or SimpleMtkWlanx)

        let kextstatCommand = ["-c", "kextstat"]
        let loadedKexts = Commands.execute(executablePath: .shell, args: kextstatCommand)
        var driverName: String?
        if let regex = try? NSRegularExpression.init(pattern: "\\b(SimpleMtkWlan\\w*)\\b", options: []), loadedKexts.0 != nil {
            let firstMatch = regex.firstMatch(in: loadedKexts.0!,
                                            options: [],
                                            range: NSRange(location: 0, length: loadedKexts.0!.count))
            if let range = firstMatch?.range(at: 1) {
                if let swiftRange = Range(range, in: loadedKexts.0!) {
                    driverName = String(loadedKexts.0![swiftRange])
                }
            }
        }

        // MARK: Output String

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        let dateRan = "Time ran: \(formatter.string(from: date))"
        let osVersion = ProcessInfo().operatingSystemVersionString
        let appOutput = """
                        \(appLog)

                        \(dateRan)
                        SimpleMTK Version: \(appVersion) (Build \(appBuildVer))

                        macOS \(osVersion)
                        """
        let driverOutput = """
                          \(driverLog)

                          \(dateRan)
                          \(driverName != nil ?  "\(driverName!) loaded version: \(driverVersion) (Firmware: \(firmwareVersion))" :
                                "Kext not loaded")

                          macOS \(osVersion)
                          """

        DispatchQueue.main.async {
            openPanel.begin { (result) in
                var folderUrl: URL?
                if result == NSApplication.ModalResponse.OK {
                    folderUrl = openPanel.url
                }

                // Back to background
                DispatchQueue.global().async {
                    guard folderUrl != nil else {
                        Log.error("Could not get path to store bug report.")
                        DispatchQueue.main.async {
                            let alert = CriticalAlert(
                                message: NSLocalizedString("Could not get path to generate bug report."),
                                options: ["Dismiss"]
                            )
                            alert.show()
                        }
                        return
                    }

                    let reportDirName = "bugreport_\(UInt16.random(in: UInt16.min...UInt16.max))"
                    let reportDirUrl = folderUrl!.appendingPathComponent(reportDirName, isDirectory: true)

                    // MARK: Write to files

                    do {
                        try FileManager.default.createDirectory(at: reportDirUrl,
                                                                withIntermediateDirectories: true,
                                                                attributes: nil)
                        let simpleMTKFile = reportDirUrl.appendingPathComponent("SimpleMTK_logs.log")
                        let driverFile = reportDirUrl.appendingPathComponent("\(driverName ?? "SimpleMtkWlan")_logs.log")
                        try appOutput.write(to: simpleMTKFile, atomically: true, encoding: .utf8)
                        try driverOutput.write(to: driverFile, atomically: true, encoding: .utf8)
                    } catch {
                        Log.error("\(error)")
                        return
                    }

                    // MARK: Zip file

                    let zipName = reportDirName + ".zip"
                    let zipCommand = ["-c", "cd \(folderUrl!.path) && " +
                                            "zip -r -X -m \(zipName) \(reportDirName)"]
                    let outputExitCode = Commands.execute(executablePath: .shell, args: zipCommand).1
                    guard outputExitCode == 0 else {
                        Log.error("Could not create zip file: Exit code: \(outputExitCode)")
                        DispatchQueue.main.async {
                            let alert = CriticalAlert(
                                message: NSLocalizedString("Could not create zip file for generated logs."),
                                options: [NSLocalizedString("Dismiss")]
                            )
                            alert.show()
                        }
                        return
                    }

                    // MARK: Select zip file

                    NSWorkspace.shared.selectFile("\(folderUrl!.path)/\(zipName)",
                                                  inFileViewerRootedAtPath: folderUrl!.path)
                }
            }
        }
    }
}

private extension String {

    // MARK: SimpleMTK Generation errors

    static let simpleMTKCouldNotGetLogs = "SIMPLEMTK-OSLOGSTORE"

    // MARK: SIMPLEMTKWLAN Generation errors

    static let msgbufInsufficient = "MSGBUF-INSUFFICIENT"
    static let scriptFailed = "SCRIPT-FAILED"

    // MARK: DOC URL
    static let dmesgHelpURL = "https://github.com/laobamac/SimpleMTKClient"
}
