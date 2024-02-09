<p align="center">
   <img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="RegionBlocker Logo">
</p>

<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat" alt="Swift 5.2">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# RegionBlocker

<p align="center">
ℹ️ A library for blocking specific application features based on the user's region
</p>

## Features
- [x]  Language check
- [x]  Region check
- [x]  Location check
- [x]  IP check
- [x]  Async/await
- [x]  iOS 12+

## Example

The example application is the best way to see `RegionBlocker` in action. Simply open the `RegionBlockerExample.xcodeproj` and run the `Example` scheme.

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/moslienko/RegionBlocker.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `RegionBlocker`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate RegionBlocker into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

### Configuring parameters

```swift
RegionService.shared.allowedRegions = [CountryCode.Russia.rawValue, CountryCode.Belarus.rawValue]
RegionService.shared.allowedLanguages = ["ru", "be"]
RegionService.shared.checkMethods = RegionBlockerMethod.allCases
```

### Checking region

To check the region, you must first call the next code (for example after the application initialization, on the splash screen, before the main screen is shown):

```swift
RegionService.shared.checkRegion { isAllowed in }
```

In the later case, you can simply refer to the variable:

```swift
RegionService.shared.isAllowed
```

### Async/await

You can also use async/await. Please note that if you choose the geolocation method, you will need to manually provide the user coordinates, for example using your own async geolocation service.

```swift
RegionService.shared.checkMethods = [.byLocation]
let isAllowed = await RegionService.shared.checkRegion(location: CLLocation(latitude: 55.7558, longitude: 37.6173))
```

### Info.plist

Depending on the region check methods selected, make sure that the required items are added to *info.plist*:

```xml
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
	<key>NSLocationWhenInUseUsageDescription</key>
    <string>To provide features available in your region</string>
```

## License

```
RegionBlocker
Copyright (c) 2024 Pavel Moslienko 8676976+moslienko@users.noreply.github.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
