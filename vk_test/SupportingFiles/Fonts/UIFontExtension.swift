import UIKit
extension UIFont {
    static func SFRegularFont(size: CGFloat) -> UIFont {
        guard let SFRegularFont = UIFont(name: "SFProDisplay-Regular", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return SFRegularFont
    }

    static func SFBoldFont(size: CGFloat) -> UIFont {
        guard let SFBoldFont = UIFont(name: "SFPro-Bold", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return SFBoldFont
    }
}
