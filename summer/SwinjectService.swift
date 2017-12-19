import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
    @objc class func setup() {
        // disable since doesn't work with storyboard plugin
        Container.loggingFunction = nil
        defaultContainer.storyboardInitCompleted(CoursesViewController.self) { r, c in
            c.documentStore = r.resolve(DocumentStore.self)
        }
        defaultContainer.storyboardInitCompleted(EventsViewController.self) { r, c in
            c.documentStore = r.resolve(DocumentStore.self)
        }
        let documentStoreSingleton = DocumentStore()
        defaultContainer.register(DocumentStore.self) { _ in documentStoreSingleton }
    }
}
