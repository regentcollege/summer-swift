# Regent College Summer App
> Browse courses, faculty, events and plan your summer at Regent College

[![Swift Version][swift-image]][swift-url]
[![License][license-image]](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Features
- [x] Course and lecturer details
- [x] FAQ
- [ ] Events
- [ ] Organize courses and events into My Plan
- [ ] Search and filter
- [ ] Directions
- [ ] Announcements
- [ ] Share to social media
- [ ] Internationalization and localization

## Architecture

- Persistent and simple datastore via [Google Firestore][firestore-url]
- Clear and simple mapping to objects via [Mapper][mapper-url]
- Clear separation of concern with MVVM
- Dependency injection via [Swinject][swinject-url] and [SwinjectStoryboard][swinject-storyboard-url]
- Embedded video via [PlayerKit][playerkit-url]
- Rich text with HTML via [Atributika][atributika-url]
- Async images via [Kingfisher][kingfisher-url]
- Responsive interface for iPad/iPhone with [SplitViews][splitview-url]

## Requirements

- iOS 10.0+
- Xcode 9

## Installation

1. Clone
1. run 'pod install'
1. Get a GoogleServices-Info.plist from the [Firestore Setup][firestore-setup-url]
1. Populate Firestore with some courses and lecturers
1. Customize [Constants.swift](summer/Constants.swift)
1. Build

## Contribute

We would love you for the contribution to **summer-swift**, check the [LICENSE](LICENSE) file for more info.

## Meta

Cam Tucker – ctucker@regent-college.edu

Distributed under the MIT license. See [LICENSE](LICENSE) for more information.

[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[firestore-url]: https://firebase.google.com/products/firestore/
[firestore-setup-url]: https://firebase.google.com/docs/ios/setup
[swinject-url]: https://github.com/Swinject/Swinject
[swinject-storyboard-url]: https://github.com/Swinject/SwinjectStoryboard
[playerkit-url]: https://github.com/vimeo/PlayerKit
[mapper-url]: https://github.com/lyft/mapper
[splitview-url]: https://developer.apple.com/documentation/uikit/uisplitviewcontroller
[kingfisher-url]: https://github.com/onevcat/Kingfisher
[atributika-url]: https://github.com/psharanda/Atributika
