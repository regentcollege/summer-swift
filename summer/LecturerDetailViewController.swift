import UIKit
import Kingfisher
import Atributika

class LecturerDetailViewController: UIViewController {
    
    @IBOutlet var lecturerImageView: UIImageView!
    @IBOutlet var lecturerNameLabel: UILabel!
    @IBOutlet var lecturerShowVideoButton: UIButton!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var stackView: UIStackView!
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

        let lecturerBio = lecturer.bio.toAttributedLabel()
        
        lecturerBio.textAlignment = NSTextAlignment.natural
        
        contentView.addSubview(lecturerBio)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        lecturerBio.translatesAutoresizingMaskIntoConstraints = false
        lecturerBio.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        lecturerBio.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        lecturerBio.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        lecturerBio.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
        
        lecturerBio.numberOfLines = 0
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
