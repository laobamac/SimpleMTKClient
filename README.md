<!--
  README.md
  SimpleMTKClient

  Created by laobamac on 2026/5/27.
  Copyright © 2026 laobamac. All rights reserved.
-->

# SimpleMTKClient

SimpleMTKClient contains `SimpleMTK`, a macOS menu bar client for
`SimpleMtkWlan.kext`.

The app talks to the `SimpleMtkWlan` IOKit service through the ClientKit ioctl
API. It can show scan results, join saved networks, manage credentials, collect
debug logs, and check for Sparkle updates from this repository.

## Repository

- Client: `https://github.com/laobamac/SimpleMTKClient`
- Driver: `https://github.com/laobamac/SimpleMtkWlan`
- App name: `SimpleMTK`
- Version: `1.0.0`
- Bundle ID: `com.laobamac.SimpleMTK`

## Requirements

- macOS 10.13 or later
- `SimpleMtkWlan.kext` loaded and publishing the `SimpleMtkWlan` IOKit service
- Xcode for building from source

## Build

Open `SimpleMTK.xcodeproj` in Xcode, or build from the command line:

```sh
xcodebuild -project SimpleMTK.xcodeproj -scheme SimpleMTK -configuration Release build
```

Debug build:

```sh
xcodebuild -project SimpleMTK.xcodeproj -scheme SimpleMTK -configuration Debug build
```

## Sparkle

Sparkle is configured to read appcast updates from:

```text
https://github.com/laobamac/SimpleMTKClient/releases/latest/download/appcast.xml
```

GitHub Actions can generate `SimpleMTK.dmg` and `appcast.xml` for releases.
Set `SPARKLE_KEY` in repository secrets before publishing signed Sparkle
updates.

## Credits

- SimpleMTKClient adaptation: laobamac
- Kernel extension target: SimpleMtkWlan by laobamac
- Original GUI client: HeliPort by OpenIntelWireless
- Original ClientKit/API work: HeliPort and upstream wireless API contributors
- Sparkle and KeychainAccess are used through Swift Package Manager

Original copyright notices are retained in source files and `Credits.rtf`.
