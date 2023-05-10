import UIKit

final class MainViewController: UIViewController {
    private var simulationInfo = SimulationInfo(
        groupSize: 0,
        infectionFactor: 0,
        period: 0
    )
    
    private lazy var alert = AlertView()
    private lazy var blurView = UIView()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = ColorPalette.mainBackground
        contentView.layer.cornerRadius = Constants.contentViewCornerRadius
        contentView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        return contentView
    }()
    
    private lazy var simulationLabel: UILabel = {
        let simulationLabel = UILabel()
        simulationLabel.translatesAutoresizingMaskIntoConstraints = false
        simulationLabel.text = Strings.simulationLabelText
        simulationLabel.textColor = ColorPalette.mainText
        simulationLabel.font = UIFont.SFBoldFont(size: Constants.labelFontSize)
        return simulationLabel
    }()
    
    private lazy var groupSizeLabel: UILabel = {
        return setupDetailsLabel(text: Strings.groupSizeLabelText)
    }()
    
    private lazy var groupSizeTextField: UITextField = {
        return setupTextField(name: Strings.groupSizeTextFieldText)
    }()
    
    private lazy var infectionFactorLabel: UILabel = {
        return setupDetailsLabel(text: Strings.infectionFactorLabelText)
    }()
    
    private lazy var infectionFactorTextField: UITextField = {
        return setupTextField(name: Strings.infectionFactorTextFieldText)
    }()
    
    private lazy var periodFactorLabel: UILabel = {
        return setupDetailsLabel(text: Strings.periodFactorLabelText)
    }()
    
    private lazy var periodTextField: UITextField = {
        return setupTextField(name: Strings.periodTextFieldText)
    }()
    
    private lazy var simulationButton: UIButton = {
        let simulationButton = UIButton()
        simulationButton.translatesAutoresizingMaskIntoConstraints = false
        simulationButton.layer.cornerRadius = Constants.buttonCornerRadius
        simulationButton.setTitle(Strings.simulationButtonTitle, for: .normal)
        simulationButton.backgroundColor = ColorPalette.buttonBackground
        simulationButton.setTitleColor(ColorPalette.buttonText, for: .normal)
        simulationButton.titleLabel?.font = UIFont.SFBoldFont(size: Constants.buttonFontSize)
        simulationButton.addTarget(self, action: #selector(simulationButtonPressed), for: .touchUpInside)
        return simulationButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    
    private func setupTextField(name: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: name,
                                                             attributes: [NSAttributedString.Key.foregroundColor: ColorPalette.placeHolder])
        textField.indent(size: Constants.textFieldLeftIndent)
        textField.textColor = ColorPalette.mainText
        textField.font = UIFont.SFRegularFont(size: Constants.textFieldFontSize)
        textField.backgroundColor = ColorPalette.textFieldBackground
        textField.layer.cornerRadius = Constants.textFieldCornerRadius
        return textField
    }
    
    private func setupDetailsLabel(text: String) -> UILabel {
        let detailsLabel = UILabel()
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.text = text
        detailsLabel.textColor = ColorPalette.placeHolder
        detailsLabel.font = UIFont.SFBoldFont(size: Constants.detailsLabelsFontSize)
        detailsLabel.numberOfLines = 0
        return detailsLabel
    }
    
    private func showAlert() {
        let blur = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        alert.frame = view.frame
        alert.center = view.center
        alert.delegate = self
        view.addSubview(alert)
    }
    
    private func setup() {
        view.backgroundColor = ColorPalette.accentColor
        [
            simulationLabel,
            groupSizeLabel,
            groupSizeTextField,
            infectionFactorLabel,
            infectionFactorTextField,
            periodFactorLabel,
            periodTextField,
            simulationButton
        ]
            .forEach {contentView.addSubview($0)}
        view.addSubview(contentView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor,
                                             constant: Constants.contentViewTopIndent),
            simulationLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                 constant: Constants.labelTopIndent),
            simulationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            groupSizeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: Constants.labelsSideIndent),
            groupSizeLabel.topAnchor.constraint(equalTo: simulationLabel.bottomAnchor,
                                                constant: Constants.labelBottomIndent),
            groupSizeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -Constants.labelsSideIndent),
            groupSizeTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            groupSizeTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                        constant: Constants.sideIndent),
            groupSizeTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                         constant: -Constants.sideIndent),
            groupSizeTextField.topAnchor.constraint(equalTo: groupSizeLabel.bottomAnchor,
                                                    constant: Constants.labelsVerticalIndent),
            infectionFactorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: Constants.labelsSideIndent),
            infectionFactorLabel.topAnchor.constraint(equalTo: groupSizeTextField.bottomAnchor,
                                                constant: Constants.textFieldVerticalIndent),
            infectionFactorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -Constants.labelsSideIndent),
            infectionFactorTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            infectionFactorTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                              constant: Constants.sideIndent),
            infectionFactorTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                               constant: -Constants.sideIndent),
            infectionFactorTextField.topAnchor.constraint(equalTo: infectionFactorLabel.bottomAnchor,
                                                          constant: Constants.labelsVerticalIndent),
            periodFactorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                    constant: Constants.labelsSideIndent),
            periodFactorLabel.topAnchor.constraint(equalTo: infectionFactorTextField.bottomAnchor,
                                                constant: Constants.textFieldVerticalIndent),
            periodFactorLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -Constants.labelsSideIndent),
            periodTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            periodTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: Constants.sideIndent),
            periodTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                      constant: -Constants.sideIndent),
            periodTextField.topAnchor.constraint(equalTo: periodFactorLabel.bottomAnchor,
                                                 constant: Constants.labelsVerticalIndent),
            simulationButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            simulationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                      constant: Constants.sideIndent),
            simulationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -Constants.sideIndent),
            simulationButton.topAnchor.constraint(equalTo: periodTextField.bottomAnchor,
                                                  constant: Constants.buttonTopIndent)
        ])
    }
    
    @objc
    private func simulationButtonPressed() {
        guard
            let groupSize = Int(groupSizeTextField.text ?? ""),
            let infectionFactor = Int(infectionFactorTextField.text ?? ""),
            let period = Double(periodTextField.text ?? "") else {
                showAlert()
                return
            }
        if groupSize<0 || infectionFactor<0 || period<0.1 || groupSize>1000000 {
            showAlert()
            return
        }
        simulationInfo = SimulationInfo(
            groupSize: groupSize,
            infectionFactor: infectionFactor,
            period: period
        )
        let simulationViewController = SimulationViewController()
        simulationViewController.delegate = self
        self.show(simulationViewController, sender: nil)
    }
}

extension MainViewController: SimulationViewControllerDelegate {
    func getSimulationInfo() -> SimulationInfo {
        return simulationInfo
    }
}

extension MainViewController: AlertViewDelegate {
    func cancelButtonPressed() {
        alert.removeFromSuperview()
        blurView.removeFromSuperview()
    }
}

private enum Constants {
    static let contentViewCornerRadius: CGFloat = 30
    static let contentViewTopIndent: CGFloat = screenHeight/5
    static let sideIndent: CGFloat = 24
    
    static let labelTopIndent: CGFloat = 40
    static let labelBottomIndent: CGFloat = 30
    static let labelFontSize: CGFloat = 30
    
    static let detailsLabelsFontSize: CGFloat = 13
    static let labelsVerticalIndent: CGFloat = 8
    static let labelsSideIndent: CGFloat = 36
    
    static let textFieldFontSize: CGFloat = 16
    static let textFieldBorderWidth: CGFloat = 1
    static let textFieldLeftIndent: CGFloat = 12
    static let textFieldVerticalIndent: CGFloat = 16
    static let textFieldCornerRadius: CGFloat = 15
    static let textFieldHeight: CGFloat = 58
    
    static let buttonFontSize: CGFloat = 18
    static let buttonTopIndent: CGFloat = 30
    static let buttonCornerRadius: CGFloat = 15
}

private enum Strings {
    static let simulationLabelText = "New simulation"
    static let groupSizeLabelText = "Number of people in the simulated group"
    static let groupSizeTextFieldText = "Group size"
    static let infectionFactorLabelText = "Number of people who can be infected by one person"
    static let infectionFactorTextFieldText = "Infection factor"
    static let periodFactorLabelText = "Period for recalculating the number of infected people"
    static let periodTextFieldText = "Recalculation period"
    static let simulationButtonTitle = "Run the simulation"
}
