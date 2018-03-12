import UIKit

class PromoCellGradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        guard let theLayer = self.layer as? CAGradientLayer else {
            return;
        }
        
        theLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.black.withAlphaComponent(0.4).cgColor, UIColor.black.cgColor]
        theLayer.locations = [0.3, 0.9, 1.0]
        theLayer.frame = self.bounds
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
}
