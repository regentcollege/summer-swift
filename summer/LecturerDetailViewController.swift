import UIKit
import Kingfisher
import Atributika

class LecturerDetailViewController: UIViewController {
    
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var lecturerBioTextView: UITextView!
    @IBOutlet var lecturerShowVideoButton: UIButton!
    
    var lecturer: LecturerViewModel! {
        didSet {
            navigationItem.title = lecturer.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lecturerNameLabel.text = lecturer.name
        
        if let imageUrl = lecturer.imageUrl {
            lecturerImageView.kf.setImage(with: imageUrl)
        } else if let placeholderImageName = lecturer.placeholderImageName {
            lecturerImageView.image = UIImage(named: placeholderImageName)
        }
        
        if lecturer.videoUrl == nil {
            lecturerShowVideoButton.isHidden = true
        }
        
        let str = lecturer.bio
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .style(tags: [Settings.Style.h1, Settings.Style.h3, Settings.Style.em, Settings.Style.strong], transformers: Settings.Style.transformers)
            .styleAll(Settings.Style.paragraph)
            .attributedString

        lecturerBioTextView.attributedText = str
        lecturerBioTextView.textContainer.lineFragmentPadding = 0
    }
    
    override func viewDidLayoutSubviews() {
        self.lecturerBioTextView.setContentOffset(.zero, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showVideo"?:
            if let videoUrl = lecturer.videoUrl {
                let videoViewController = segue.destination as! VideoViewController
                videoViewController.videoUrl = videoUrl
            }
        default:
            preconditionFailure("Unexpected segue identifer")
        }
    }
}
