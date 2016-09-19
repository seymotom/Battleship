//
//  BattleshipViewController.swift
//  Battleship
//
//  Created by The TEAM on 9/17/16.
//  Copyright © 2016 C4Q. All rights reserved.
//


import UIKit

class BattleshipViewController: UIViewController {
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!    
    @IBOutlet weak var scoreCard: UILabel!
    
    let howManySquares: Int
    let howManyColumns: Int
    
    let brain: BattleBrain
    var loaded: Bool
    let resetTitle = "RESET"
    
    var missCounter = 0
    var currentScore = 100
    var scores: [Int] = [0, 0, 0]
    
    required init?(coder aDecoder: NSCoder) {
        self.howManySquares = 100     //Must be a square number... 36, 49, 64, 81, 100, 121 or 144
        self.howManyColumns = Int(sqrt(Double(self.howManySquares)))
        self.loaded = false
        self.brain = BattleBrain(numSquares: self.howManySquares, numColumns: self.howManyColumns)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        if !loaded {
            setUpGameButtons(v: buttonContainer, totalButtons: self.howManySquares, buttonsPerRow: howManyColumns)
            self.view.setNeedsDisplay()
        }
        loaded = true
    }
    
    func resetButtonColors() {
        for v in buttonContainer.subviews {
            if let button = v as? UIButton {
                button.backgroundColor = UIColor.blue
                button.isEnabled = true
            }
        }
    }
    
    func handleReset() {
        resetButtonColors()
        brain.setupSquares(n: howManySquares, col: howManyColumns)
        setUpGameLabel()
        scoreCard.text = ""
        scoreCard.backgroundColor = .white
    }
    
    func disableCardButtons() {
        for v in buttonContainer.subviews {
            if let button = v as? UIButton {
                button.isEnabled = false
            }
        }
    }
    
    func processScore() {
        scores.append(currentScore)
        currentScore = 100
        missCounter = 0
        let topScores = scores.sorted(by: >)
        scoreCard.backgroundColor = .blue
        scoreCard.text = "HIGH SCORES: \n1: \(topScores[0]) \n2: \(topScores[1]) \n3: \(topScores[2])"
        

    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        handleReset()
    }
        
    func buttonTapped(_ sender: UIButton) {
        gameLabel.text = sender.currentTitle
        
        if brain.checkSquare(sender.tag - 1) {
            gameLabel.text = "YOU HIT MY \(brain.currentShipType)"
            sender.backgroundColor = UIColor.red
            sender.isEnabled = false
            scoreCard.backgroundColor = .blue
            currentScore += 50
            scoreCard.text = "SCORE: \(currentScore)"
            if brain.sunkShip(ship: brain.currentShipType) == true {
                gameLabel.text = "YOU SUNK MY \(brain.currentShipType)"
                currentScore *= 2
                scoreCard.backgroundColor = .blue
                scoreCard.text = "SCORE: \(currentScore)"
            }
            if brain.checkWin() == true {
                disableCardButtons()
                gameLabel.text = "YOU SUNK ALL MY SHIPS!!!"
                processScore()
            }
        } else {
            gameLabel.text = "MISS"
            sender.backgroundColor = UIColor.lightGray
            sender.isEnabled = false
            missCounter += 1
            currentScore -= missCounter
            scoreCard.backgroundColor = .red
            scoreCard.text = "SCORE: \(currentScore)"
        }
    }
    
    func setUpGameLabel () {
        gameLabel.text = "PLAY BATTLESHIP"
    }
    
    func setUpGameButtons(v: UIView, totalButtons: Int, buttonsPerRow : Int) {
        for i in 1...howManySquares {
            let y = ((i - 1) / buttonsPerRow)
            let x = ((i - 1) % buttonsPerRow)
            let side : CGFloat = v.bounds.size.width / CGFloat(buttonsPerRow)
            
            let rect = CGRect(origin: CGPoint(x: side * CGFloat(x), y: (CGFloat(y) * side)), size: CGSize(width: side - 1, height: side - 1))
            let button = UIButton(frame: rect)
            button.tag = i
            button.backgroundColor = UIColor.blue
            button.setTitle("\(i)", for: UIControlState())
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            v.addSubview(button)
        }
        setUpGameLabel()
    }
}

