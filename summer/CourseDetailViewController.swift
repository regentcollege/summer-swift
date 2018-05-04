import UIKit
import Kingfisher
import Atributika
import ImageSlideshow

class CourseDetailViewController: UIViewController {
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var courseDescriptionTitleLabel: UILabel!
    @IBOutlet var courseDateLabel: UILabel!
    @IBOutlet var courseTimeLabel: UILabel!
    @IBOutlet var detailChevronImage: UIImageView!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet var stackView: UIStackView!
    var courseDescription: AttributedLabel?
    
    var course: CourseViewModel! {
        didSet {
            navigationItem.title = course.title
        }
    }
    var lecturer: LecturerViewModel!
    var room: RoomViewModel?
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if course == nil || lecturer == nil {
            return
        }
        
        if #available(iOS 11.0, *) {
            // table layout is fine
        }
        else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        lecturerNameLabel.text = lecturer.name

        if let imageUrl = lecturer.imageUrl {
            let cropProcessor = CroppingImageProcessor(size: CGSize(width: 240, height: 300), anchor: CGPoint(x: 0, y: 0))
            lecturerImageView.kf.setImage(with: imageUrl, options: [.processor(cropProcessor)])
        } else if let placeholderImageName = lecturer.placeholderImageName {
            lecturerImageView.image = UIImage(named: placeholderImageName)
        }
        
        if !lecturer.hasDetail {
            detailChevronImage.isHidden = true
        }
        
        if let room = room {
            roomLabel.text = room.title
            
            if let directionImageUrls = room.directionImageUrls, directionImageUrls.count > 0 {
                directionsButton.isHidden = false
                
                let kingfisher = directionImageUrls.map { KingfisherSource(url: $0) }
                slideshow.setImageInputs(kingfisher)
                
                slideshow.slideshowInterval = 0
            }
        }
        
        courseDescriptionTitleLabel.text = course.title
        courseDescriptionTitleLabel.textColor = Settings.Color.blue
        
        // the cell can be reused, so don't lay this out more than once
        if courseDescription == nil {
            let courseDescriptionBuilder = course.description.toAttributedLabel()
            courseDescriptionBuilder.textAlignment = NSTextAlignment.natural
            courseDescriptionBuilder.lineBreakMode = NSLineBreakMode.byWordWrapping
            courseDescriptionBuilder.numberOfLines = 0
            
            courseDescription = courseDescriptionBuilder
            
            stackView.addArrangedSubview(courseDescriptionBuilder)
        }
        
        courseDateLabel.text = course.dates
        courseTimeLabel.text = course.meetingTime
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !lecturer.hasDetail { return false }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showLecturer"?:
            if lecturer.hasDetail {
                let lecturerDetailViewController = segue.destination as! LecturerDetailViewController
                lecturerDetailViewController.lecturer = lecturer
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
    
    @objc func share(sender:UIView){
        let content = URL(string: "courses/course-details?course_id=" + course.name, relativeTo: Settings.Url.baseURL)!
        let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func toggleDirections(_ sender: UIButton) {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}
