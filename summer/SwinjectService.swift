import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.storyboardInitCompleted(CoursesViewController.self) { r, c in
            c.documentStore = r.resolve(DocumentStore.self)
        }
        defaultContainer.register(DocumentStore.self) { _ in DocumentStore() }
    }
}
