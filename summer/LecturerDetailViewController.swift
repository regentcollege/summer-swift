import UIKit
import Kingfisher
import Atributika

class LecturerDetailViewController: UIViewController {
    
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var lecturerBioTitleLabel: UILabel!
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
        
        lecturerBioTitleLabel.text = "About"
        
        let h1 = Style("h1").font(Config.headerFont)
        let em = Style("em").font(Config.obliqueFont)
        let str = lecturer.bio.style(tags: h1, em)
            .styleAll(Style.font(Config.paragraphFont))
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
