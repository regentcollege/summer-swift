# Regent College Summer App
> Experience summer at Regent College

[![Swift Version][swift-image]][swift-url]
[![License][license-image]](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Features
- [x] Course and lecturer details
- [x] FAQ
- [x] Events
- [x] What's happening today
- [ ] Search and filter
- [ ] Directions
- [ ] Announcements
- [ ] Share to social media
- [ ] [Today extension](https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/Today.html) for lock screen
- [ ] WatchKit
- [ ] Internationalization and localization

## Architecture

- Persistent and simple datastore with [Google Firestore][firestore-url]
- Clear and simple mapping to objects with [Mapper][mapper-url]
- Dependency injection with [Swinject][swinject-url] and [SwinjectStoryboard][swinject-storyboard-url]
- Embedded video with [PlayerKit][playerkit-url]
- Rich text with HTML with [Atributika][atributika-url]
- Async images with [Kingfisher][kingfisher-url]
- Responsive interface for iPad/iPhone with [SplitViews][splitview-url]

### MVC/MVVM

> "Isolate complexity" - Steve McConnell, *Code Complete*

Here is how this project isolates complexity:
- **Model**: Data, including the means to instantiate from source; in this case it is Firestore NSDictionary.
- **ViewModel**: Data formed for specific view purposes. Only show data from the model that the view actually needs. Combine and massage fields with presentation logic.
- **DocumentStore** (aka repository): Data CRUD (create, read, update, delete). This service is injected into the ViewControllers, sets them as its delegate, and tells them when it has updates with documentsDidUpdate().
- **DetailViewControllers** and **TableViewCells**: A view with injected ViewModel(s).
- **ViewController**: Everything else. Use extensions to separate concerns.

## Requirements

- iOS 10.0+
- Xcode 9

## Installation

1. Clone
1. run 'pod install'
1. Get a GoogleServices-Info.plist from the [Firestore Setup][firestore-setup-url]
1. Populate Firestore with some courses and lecturers
1. Customize [Settings.swift](summer/Settings.swift)
1. Build

## Contribute

Check the [LICENSE](LICENSE) file for more info on contributing to **summer-swift**.

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
