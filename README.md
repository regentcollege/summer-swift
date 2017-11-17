# Regent College Summer App
> Browse courses, faculty, events and plan your summer at Regent College

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Features

- Persistent and simple datastore via [Google Firestore][firestore-url]
- Clear and simple mapping to objects via [Mapper][mapper-url]
- Clear separation of concern with MVVM
- Dependency injection via [Swinject][swinject-url]
- Embedded video via [PlayerKit][playerkit-url]
- Unified interface for iPad/iPhone with [SplitViews][splitview-url]

## Requirements

- iOS 10.0+
- Xcode 9

## Installation

1. Clone
2. run 'pod install'
3. Get a GoogleServices-Info.plist from the [Firestore Setup][firestore-setup-url]
4. Populate Firestore with some courses and lecturers
5. Build

## Contribute

We would love you for the contribution to **summer-swift**, check the [LICENSE][license-url] file for more info.

## Meta

Cam Tucker – ctucker@regent-college.edu

Distributed under the MIT license. See [LICENSE][license-url] for more information.

[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: https://github.com/RegentCollege/summer-swift/blob/master/LICENSE
[firestore-url]: https://firebase.google.com/products/firestore/
[firestore-setup-url]: https://firebase.google.com/docs/ios/setup
[swinject-url]: https://github.com/Swinject/Swinject
[playerkit-url]: https://github.com/vimeo/PlayerKit
[mapper-url]: https://github.com/lyft/mapper
[splitview-url]: https://developer.apple.com/documentation/uikit/uisplitviewcontroller
