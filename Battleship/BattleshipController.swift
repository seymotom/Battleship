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
    
    let howManySquares: Int
    let howManyColumns: Int
    
    let brain: BattleBrain
    var loaded: Bool
    let resetTitle = "RESET"
    
    required init?(coder aDecoder: NSCoder) {
        self.howManySquares = 100
        self.howManyColumns = 10
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
    }
    
    func disableCardButtons() {
        for v in buttonContainer.subviews {
            if let button = v as? UIButton {
                button.isEnabled = false
            }
        }
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
            if brain.sunkShip(ship: brain.currentShipType) == true {
                gameLabel.text = "YOU SUNK MY \(brain.currentShipType)"
            }
            if brain.checkWin() == true {
                disableCardButtons()
                gameLabel.text = "YOU SUNK ALL MY SHIPS!!!"
            }                        
        } else {
            gameLabel.text = "MISS"
            sender.backgroundColor = UIColor.lightGray
            sender.isEnabled = false
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
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            v.addSubview(button)
        }
        setUpGameLabel()
    }
}

