import UIKit
import Kingfisher
import Atributika

class CourseDetailViewController: UIViewController {
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var courseDescriptionTitleLabel: UILabel!
    @IBOutlet var courseDateLabel: UILabel!
    @IBOutlet var courseTimeLabel: UILabel!
    @IBOutlet var detailChevronImage: UIImageView!
    
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var directionsCollectionView: UICollectionView!
    @IBOutlet var stackView: UIStackView!
    var courseDescription: AttributedLabel?
    
    var course: CourseViewModel! {
        didSet {
            navigationItem.title = course.title
        }
    }
    var lecturer: LecturerViewModel!
    var room: RoomViewModel?
    
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
            directionsButton.setTitle(room.title, for: .normal)
            directionsButton.isHidden = false
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
    
    @IBAction func toggleDirections(_ sender: UIButton) {
        directionsCollectionView.isHidden = !directionsCollectionView.isHidden
    }
}

extension CourseDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let room = room, let directionImageUrls = room.directionImageUrls {
            return directionImageUrls.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = directionsCollectionView.dequeueReusableCell(withReuseIdentifier: "DirectionCell", for: indexPath) as? DirectionCell, let room = room, let directionImageUrls = room.directionImageUrls {
            cell.configureWith(directionImageUrl: directionImageUrls[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }    
}

extension CourseDetailViewController: UICollectionViewDelegate {
    
}
