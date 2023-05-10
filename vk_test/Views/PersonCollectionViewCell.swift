import Foundation
import UIKit

final class PersonCollectionViewCell: UICollectionViewCell {

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "suit.heart.fill")
        view.tintColor = ColorPalette.lightGreen
        view.contentMode = .scaleAspectFit
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        imageView.frame = contentView.frame
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setup() {
        contentView.backgroundColor = ColorPalette.mainBackground
        contentView.addSubview(imageView)
    }
    
    func configure(with status: Int) {
        if status == 1 {
            imageView.tintColor = ColorPalette.lightRed
        } else {
            imageView.tintColor = ColorPalette.lightGreen
        }
    }
}
