import UIKit

class ViewController: UIViewController, UITableViewDelegate {

  fileprivate let mainStopwatch: Stopwatch = Stopwatch()
  fileprivate let lapStopwatch: Stopwatch = Stopwatch()
  fileprivate var isPlay: Bool = false
  fileprivate var laps: [String] = []


  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var lapTimerLabel: UILabel!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var lapRestButton: UIButton!
  @IBOutlet weak var lapsTableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
  
        let initRoundedButton: (UIButton) -> Void = { button in
            button.layer.cornerRadius = 10.0 
            button.backgroundColor = UIColor.purple 
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.shadowColor = UIColor.darkGray.cgColor
            button.layer.shadowOffset = CGSize(width: 3, height: 3)
            button.layer.shadowOpacity = 0.4
            button.layer.shadowRadius = 5.0
            button.tintColor = UIColor.white
        }
        
      
        initRoundedButton(playPauseButton)
        initRoundedButton(lapRestButton)
        
    
        lapRestButton.isEnabled = false
        
     
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
        
    
        lapsTableView.separatorStyle = .singleLine
        lapsTableView.separatorColor = UIColor.darkGray
        lapsTableView.rowHeight = 70
        lapsTableView.backgroundColor = UIColor(white: 0.95, alpha: 1) 
        lapsTableView.layer.borderWidth = 1.5
        lapsTableView.layer.borderColor = UIColor.gray.cgColor
        lapsTableView.layer.cornerRadius = 12.0
        lapsTableView.clipsToBounds = true
    }


  override var shouldAutorotate : Bool {
    return false
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
  
  @IBAction func playPauseTimer(_ sender: AnyObject) {
    lapRestButton.isEnabled = true
  
    changeButton(lapRestButton, title: "Lap", titleColor: UIColor.black)
    
    if !isPlay {
      unowned let weakSelf = self
      
      mainStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateMainTimer, userInfo: nil, repeats: true)
      lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateLapTimer, userInfo: nil, repeats: true)
      
      RunLoop.current.add(mainStopwatch.timer, forMode: RunLoop.Mode.common)
      RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
      
      isPlay = true
      changeButton(playPauseButton, title: "Stop", titleColor: UIColor.red)
    } else {
      
      mainStopwatch.timer.invalidate()
      lapStopwatch.timer.invalidate()
      isPlay = false
      changeButton(playPauseButton, title: "Start", titleColor: UIColor.green)
      changeButton(lapRestButton, title: "Reset", titleColor: UIColor.black)
    }
  }
  
  @IBAction func lapResetTimer(_ sender: AnyObject) {
    if !isPlay {
      resetMainTimer()
      resetLapTimer()
      changeButton(lapRestButton, title: "Lap", titleColor: UIColor.lightGray)
      lapRestButton.isEnabled = false
    } else {
      if let timerLabelText = timerLabel.text {
        laps.append(timerLabelText)
      }
      lapsTableView.reloadData()
      resetLapTimer()
      unowned let weakSelf = self
      lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateLapTimer, userInfo: nil, repeats: true)
      RunLoop.current.add(lapStopwatch.timer, forMode: RunLoop.Mode.common)
    }
  }
  
  fileprivate func changeButton(_ button: UIButton, title: String, titleColor: UIColor) {
    button.setTitle(title, for: UIControl.State())
    button.setTitleColor(titleColor, for: UIControl.State())
  }
  
  fileprivate func resetMainTimer() {
    resetTimer(mainStopwatch, label: timerLabel)
    laps.removeAll()
    lapsTableView.reloadData()
  }
  
  fileprivate func resetLapTimer() {
    resetTimer(lapStopwatch, label: lapTimerLabel)
  }
  
  fileprivate func resetTimer(_ stopwatch: Stopwatch, label: UILabel) {
    stopwatch.timer.invalidate()
    stopwatch.counter = 0.0
    label.text = "00:00:00"
  }

  @objc func updateMainTimer() {
    updateTimer(mainStopwatch, label: timerLabel)
  }
  
  @objc func updateLapTimer() {
    updateTimer(lapStopwatch, label: lapTimerLabel)
  }
  
  func updateTimer(_ stopwatch: Stopwatch, label: UILabel) {
    stopwatch.counter = stopwatch.counter + 0.035
    
    var minutes: String = "\((Int)(stopwatch.counter / 60))"
    if (Int)(stopwatch.counter / 60) < 10 {
      minutes = "0\((Int)(stopwatch.counter / 60))"
    }
    
    var seconds: String = String(format: "%.2f", (stopwatch.counter.truncatingRemainder(dividingBy: 60)))
    if stopwatch.counter.truncatingRemainder(dividingBy: 60) < 10 {
      seconds = "0" + seconds
    }
    
    label.text = minutes + ":" + seconds
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return laps.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier: String = "lapCell"
    let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

    if let labelNum = cell.viewWithTag(11) as? UILabel {
      labelNum.text = "Lap \(laps.count - indexPath.row)"
      labelNum.textColor = UIColor.blue 
    }

    if let labelTimer = cell.viewWithTag(12) as? UILabel {
      labelTimer.text = laps[laps.count - indexPath.row - 1]
      labelTimer.textColor = UIColor.red  
    }
    
    return cell
  }
}


fileprivate extension Selector {
  static let updateMainTimer = #selector(ViewController.updateMainTimer)
  static let updateLapTimer = #selector(ViewController.updateLapTimer)
}
