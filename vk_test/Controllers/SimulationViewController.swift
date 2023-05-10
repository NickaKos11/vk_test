import UIKit

protocol SimulationViewControllerDelegate: AnyObject {
    func getSimulationInfo() -> SimulationInfo
}

final class SimulationViewController: UIViewController {
    weak var delegate: SimulationViewControllerDelegate?
    
    private var timer: Timer?
    private var isPaused = false
    
    private var simulationInfo: SimulationInfo?
    private var points = [Int]()
    private var queue = Queue(array: [Int]())
    private var healthyCount = 0
    private var infectedCount = 0
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let totalInterItemSpasing = Constants.interItemSpacing*(Constants.maxRowItemsNumber-1)
        let totalSideIndent = 2*Constants.sideIndent
        let availableWidth = screenWidth - totalInterItemSpasing - totalSideIndent
        let size = availableWidth/Constants.maxRowItemsNumber
        collectionViewLayout.itemSize = CGSize(width: size, height: size)
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = ColorPalette.mainBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            PersonCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: PersonCollectionViewCell.self)
        )
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        return collectionView
    }()
    
    private lazy var infoView: UIView = {
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = ColorPalette.lightBackground
        infoView.layer.cornerRadius = Constants.infoViewCornerRadius
        return infoView
    }()
    
    private lazy var healthyPeopleLabel: UILabel = {
        let healthyPeopleLabel = UILabel()
        healthyPeopleLabel.translatesAutoresizingMaskIntoConstraints = false
        healthyPeopleLabel.text = Strings.healthyPeopleLabelText
        healthyPeopleLabel.textColor = ColorPalette.mainText
        healthyPeopleLabel.font = UIFont.SFBoldFont(size: Constants.labelsFontSize)
        return healthyPeopleLabel
    }()
    
    private lazy var infectedPeopleLabel: UILabel = {
        let infectedPeopleLabel = UILabel()
        infectedPeopleLabel.translatesAutoresizingMaskIntoConstraints = false
        infectedPeopleLabel.text = Strings.infectedPeopleLabelText
        infectedPeopleLabel.textColor = ColorPalette.mainText
        infectedPeopleLabel.font = UIFont.SFBoldFont(size: Constants.labelsFontSize)
        return infectedPeopleLabel
    }()
    
    private lazy var healthyCountLabel: UILabel = {
        let healthyCountLabel = UILabel()
        healthyCountLabel.translatesAutoresizingMaskIntoConstraints = false
        healthyCountLabel.textColor = ColorPalette.lightGreen
        healthyCountLabel.font = UIFont.SFBoldFont(size: Constants.labelsFontSize)
        return healthyCountLabel
    }()
    
    private lazy var infectedCountLabel: UILabel = {
        let infectedCountLabel = UILabel()
        infectedCountLabel.translatesAutoresizingMaskIntoConstraints = false
        infectedCountLabel.text = "\(infectedCount)"
        infectedCountLabel.textColor = ColorPalette.lightRed
        infectedCountLabel.font = UIFont.SFBoldFont(size: Constants.labelsFontSize)
        return infectedCountLabel
    }()
    
    private lazy var pausePlayButton: UIButton = {
        let pausePlayButton = UIButton()
        pausePlayButton.translatesAutoresizingMaskIntoConstraints = false
        pausePlayButton.layer.cornerRadius = Constants.buttonCornerRadius
        pausePlayButton.backgroundColor = ColorPalette.accentColor
        pausePlayButton.tintColor = ColorPalette.buttonText
        pausePlayButton.setImage(UIImage(systemName: "pause"), for: .normal)
        pausePlayButton.addTarget(self, action: #selector(pauseButtonPressed), for: .touchUpInside)
        return pausePlayButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
        setNavBarAppearance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        cancelTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let indexPaths = collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths {
                points[indexPath.row] = 1
            }
        }
    }
    
    @objc
    private func pauseButtonPressed() {
        if isPaused{
            createTimer()
        } else {
            cancelTimer()
        }
    }
    
    private func setNavBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorPalette.mainText]
        navigationBarAppearance.backgroundColor = ColorPalette.mainBackground
        self.navigationController?.navigationBar.tintColor = ColorPalette.mainText
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    private func setup() {
        view.backgroundColor = ColorPalette.mainBackground
        simulationInfo = self.delegate?.getSimulationInfo()
        let groupSize = simulationInfo?.groupSize ?? 0
        healthyCount = groupSize
        points = Array(repeating: 0, count: groupSize)
        healthyCountLabel.text = "\(groupSize)"
        [
            healthyPeopleLabel,
            infectedPeopleLabel,
            healthyCountLabel,
            infectedCountLabel,
            pausePlayButton
        ]
            .forEach {infoView.addSubview($0)}
        [
            collectionView,
            infoView
        ]
            .forEach {view.addSubview($0)}
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                              constant: Constants.sideIndent),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                               constant: -Constants.sideIndent),
            healthyPeopleLabel.topAnchor.constraint(equalTo: infoView.topAnchor,
                                                    constant: Constants.labelsVertivalIndent),
            healthyPeopleLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor,
                                                        constant: Constants.labelsSideIndent),
            infectedPeopleLabel.topAnchor.constraint(equalTo: infoView.topAnchor,
                                                     constant: Constants.labelsVertivalIndent),
            infectedPeopleLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor,
                                                          constant: -Constants.labelsSideIndent),
            healthyCountLabel.centerXAnchor.constraint(equalTo: healthyPeopleLabel.centerXAnchor),
            healthyCountLabel.topAnchor.constraint(equalTo: healthyPeopleLabel.bottomAnchor,
                                                   constant: Constants.labelsVertivalIndent),
            healthyCountLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor,
                                                      constant: -Constants.labelsVertivalIndent),
            infectedCountLabel.centerXAnchor.constraint(equalTo: infectedPeopleLabel.centerXAnchor),
            infectedCountLabel.topAnchor.constraint(equalTo: infectedPeopleLabel.bottomAnchor,
                                                    constant: Constants.labelsVertivalIndent),
            infectedCountLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor,
                                                       constant: -Constants.labelsVertivalIndent),
            pausePlayButton.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),
            pausePlayButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
            pausePlayButton.widthAnchor.constraint(equalToConstant: Constants.buttonSide),
            pausePlayButton.heightAnchor.constraint(equalToConstant: Constants.buttonSide),
            collectionView.topAnchor.constraint(equalTo: infoView.bottomAnchor,
                                                constant: Constants.labelsVertivalIndent),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: Constants.sideIndent),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -Constants.sideIndent)
        ])
    }
}

extension SimulationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return simulationInfo?.groupSize ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PersonCollectionViewCell.self),
                    for: indexPath) as? PersonCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.configure(with: points[indexPath.row])
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if points[indexPath.row] != 1 {
            healthyCountLabel.text = "\(healthyCount-1)"
            infectedCountLabel.text = "\(infectedCount+1)"
            self.points[indexPath.row] = 1
            collectionView.reloadItems(at:[indexPath])
            infectManually(personId: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        self.setEditing(true, animated: true)
    }
}

    extension SimulationViewController: UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return Constants.interItemSpacing
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return Constants.interItemSpacing
        }
    }

extension SimulationViewController {
    private func automaticInfection() {
        DispatchQueue.global(qos: .userInitiated).async {
            var infectedNow = [Int]()
            let queueSize = self.queue.size()
            for _ in 0..<queueSize {
                if let first = self.queue.pop() {
                        let neighbours = self.infectNeighbours(person: first)
                        for i in neighbours {
                            if self.points[i] == 0 {
                                self.points[i] = 1
                                infectedNow.append(i)
                                self.infectedCount+=1
                                self.healthyCount-=1
                                self.queue.push(i)
                            }
                        }
                }
            }
            let indexPaths = infectedNow.map {IndexPath(row: $0, section: 0)}
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: indexPaths)
                self.healthyCountLabel.text = "\(self.healthyCount)"
                self.infectedCountLabel.text = "\(self.infectedCount)"
            }
        }
    }

    private func infectNeighbours(person: Int) -> Set<Int> {
        let infectionFactor = simulationInfo?.infectionFactor ?? 0
        let neighbours = findNeighbours(person: person)
        var infected = Set<Int>()
        
        for _ in 0..<infectionFactor {
            if neighbours.count > 0 {
                let randomIndex = Int.random(in: 0..<neighbours.count)
                infected.insert(neighbours[randomIndex])
            }
        }
        return infected
    }
    
    private func findNeighbours(person: Int) -> [Int] {
        let maxRowItemsNumber = Int(Constants.maxRowItemsNumber)
        var neighbours = [Int]()
        if checkLeftBoarder(person) { // left neighbour
            neighbours.append(person-1)
            if checkTopBoarder(person-1) { // top left neighbour
                neighbours.append(person-maxRowItemsNumber-1)
            }
            if checkBottomBoarder(person-1) { // bottom left neighbour
                neighbours.append(person+maxRowItemsNumber-1)
            }
        }
        
        if checkTopBoarder(person) { // top neighbour
            neighbours.append(person-maxRowItemsNumber)
            if checkRightBoarder(person-maxRowItemsNumber) { // top right neighbour
                neighbours.append(person-maxRowItemsNumber+1)
            }
        }
        
        if checkBottomBoarder(person) { // bottom neighbour
            neighbours.append(person+maxRowItemsNumber)
            if checkRightBoarder(person+maxRowItemsNumber) { // bottom right neighbour
                neighbours.append(person+maxRowItemsNumber+1)
            }
        }
        
        if checkRightBoarder(person) { // right neighbour
            neighbours.append(person+1)
        }
        return neighbours
    }
    
    private func checkLeftBoarder(_ person: Int) -> Bool {
        let x = person % Int(Constants.maxRowItemsNumber)
        return x>0
    }
    
    private func checkRightBoarder(_ person: Int) -> Bool {
        let size = simulationInfo?.groupSize ?? 0
        let x = person % Int(Constants.maxRowItemsNumber)
        return x<Int(Constants.maxRowItemsNumber)-1 && person<size-1
    }
    
    private func checkTopBoarder(_ person: Int) -> Bool {
        let y = person / Int(Constants.maxRowItemsNumber)
        return y>0
    }
    
    private func checkBottomBoarder(_ person: Int) -> Bool {
        let size = simulationInfo?.groupSize ?? 0
        return person+Int(Constants.maxRowItemsNumber)<size
    }
    
    private func infectManually(personId: Int) {
        self.queue.push(personId)  // это на бэкграунд?
        self.infectedCount+=1
        self.healthyCount-=1
        createTimer()
    }
}

// MARK: - Timer
extension SimulationViewController {
    private func createTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: TimeInterval(simulationInfo?.period ?? 1),
                            target: self,
                            selector: #selector(updateTimer),
                            userInfo: nil,
                            repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
            
            pausePlayButton.setImage(UIImage(systemName: "pause"), for: .normal)
            isPaused = false
        }
    }

    @objc
    private func updateTimer() {
        if self.queue.size() != 0 {
            automaticInfection()
        } else {
            cancelTimer()
        }
    }

    private func cancelTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            pausePlayButton.setImage(UIImage(systemName: "play"), for: .normal)
            isPaused = true
        }
    }
}

private enum Constants {
    static let maxRowItemsNumber: CGFloat = 15
    static let interItemSpacing: CGFloat = 2
    static let sideIndent: CGFloat = 12
    
    static let infoViewCornerRadius: CGFloat = 16

    static let labelsFontSize: CGFloat = 17
    static let labelsVertivalIndent: CGFloat = 12
    static let labelsSideIndent: CGFloat = 24
    
    static let buttonCornerRadius: CGFloat = 15
    static let buttonSide: CGFloat = 40
}

private enum Strings {
    static let healthyPeopleLabelText = "Healthy"
    static let infectedPeopleLabelText = "Infected"
}
