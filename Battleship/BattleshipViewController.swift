//
//  BattleshipViewController.swift
//  Battleship
//
//  Created by Jason Gresh on 9/16/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit

class BattleshipViewController: UIViewController {
    
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let brain: BattleshipBrain
    
    var gameBoardBeingSet = true
    var buttonTappedCounter = 0
    
    required init?(coder aDecoder: NSCoder) {
        self.brain = BattleshipBrain(rows: 10, columns: 10)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // better than viewDidLayoutSubviews but not all the way there
        self.view.layoutIfNeeded()
        startGame()
    }
    
    func buttonTapped(_ sender: UIButton) {
        // our tag is one-based so we subtract 1 before indexing
        let r = (sender.tag - 1) / brain.columns
        let c = (sender.tag - 1) % brain.columns
        buttonTappedCounter += 1
        
        if gameBoardBeingSet {
            sender.backgroundColor = .yellow
            sender.isEnabled = false
            switch buttonTappedCounter {
            case 0:
                messageLabel.text = "ERROR"
            case 1...5:
                brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .carrier))
                if buttonTappedCounter == 5 {
                    messageLabel.text = "CARRIER SET.\nPLACE YOUR BATTLESHIP\nON 4 CONSECUTIVE SQUARES."
                }
            case 6...9:
                brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .battleship))
                if buttonTappedCounter == 9 {
                    messageLabel.text = "BATTLESHIP SET.\nPLACE YOUR CRUISER\nON 3 CONSECUTIVE SQUARES."
                }
            case 10...12:
                brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .cruiser))
                if buttonTappedCounter == 12 {
                    messageLabel.text = "CRUISER SET.\nPLACE YOUR SUBMARINE\nON 3 CONSECUTIVE SQUARES."
                }
            case 13...15:
                brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .submarine))
                if buttonTappedCounter == 15 {
                    messageLabel.text = "SUBMARINE SET.\nPLACE YOUR DESTROYER\nON 2 CONSECUTIVE SQUARES."
                }
            case 16...17:
                brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .destroyer))
                if buttonTappedCounter == 17 {
                    messageLabel.text = "DESTROYER SET.\nALL SHIPS NOW SET\nCLICK A BLUE GAME SQUARE TO START."
                }
            case 18:
                drawBoard()
                messageLabel.text = "PLAY BATTLESHIP."
                gameBoardBeingSet = false
                enableGameButtons(view: gridView)
            default:
                break
            }


        } else {
            // note how the strike itself isn't updating the interface
            _ = brain.strike(atRow: r, andColumn: c)
            drawBoard()
            let currentSquare = brain.getCurrentSquare(r: r, c: c)
            switch currentSquare {
            case .empty(_):
                messageLabel.text = "MISS"
            case .occupied(_, let ship):
                messageLabel.text = "YOU HIT MY \(ship.rawValue)"
                            }
            if case .occupied(_, let ship) = currentSquare {
                if brain.shipSunk(ship: ship) {
                    messageLabel.text = "WITH THE FUNCTION\nYOU SUNK MY \(ship.rawValue)"
                }
            }
            
            // check for win
            if brain.gameFinished() {
                messageLabel.text = "YOU SUNK ALL SHIPS.\nWINNER!"
                disableGameButtons(view: gridView)
            }
        }
    }
    
    func drawBoard() {
        for r in 0..<brain.rows {
            for c in 0..<brain.columns {
                // find the button by tag
                // our tag is one-based so we add 1
                if let button = gridView.viewWithTag(r * brain.columns + c + 1) as? UIButton {
                    
                    // funky subscript call with two indexes ([r][c] doesn't seem to work)
                    switch brain[r, c] {
                    case .empty(let state):
                        switch state {
                        case .shown:
                            button.backgroundColor = UIColor.lightGray
                        case .hidden:
                            button.backgroundColor = UIColor.blue
                        }
                    case .occupied(let state, _):
                        switch state {
                        case .shown:
                            button.backgroundColor = UIColor.red
                        case .hidden:
                            button.backgroundColor = UIColor.blue
                        }
                    }
                }
            }
        }
    }
    
    func setUpGameButtons(v: UIView) {
        // remove all views from the container
        // this helps both with resetting and if viewDidLayoutSubviews is called more than once
        for v in v.subviews {
            v.removeFromSuperview()
        }
        
        let side : CGFloat = v.bounds.size.width / CGFloat(brain.rows)
        for row in 0..<brain.rows {
            for col in 0..<brain.columns {
                
                let rect = CGRect(origin: CGPoint(x: CGFloat(row) * side,
                                                  y: CGFloat(col) * side),
                                  size: CGSize(width: side - 1, height: side - 1))
                let button = UIButton(frame: rect)
                
                // this flattens the 2d matrix into a sequence of numbers
                // our tag is one-based so we add 1
                button.tag = row * brain.columns + col + 1
                
                let letter = String(Character(UnicodeScalar(65 + row)!))
                button.setTitle("\(letter)\(col + 1)", for: UIControlState())
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                v.addSubview(button)
            }
        }
        drawBoard()
    }
    
    @IBAction func computerPlayer(_ sender: UIButton) {
        messageLabel.text = "Ships set. CPU now playing."
        gameBoardBeingSet = true
        drawBoard()
        cpuPlaysTheGame()
        
    }
    
    func cpuPlaysTheGame() {
        outer: for r in 0..<brain.rows {
            inner: for c in 0..<brain.columns {
                // note how the strike itself isn't updating the interface
                _ = brain.strike(atRow: r, andColumn: c)
                
                // redraw the whole board
                drawBoard()
                
                // check for win
                if brain.gameFinished() {
                    messageLabel.text = "CPU wins!"
                    disableGameButtons(view: gridView)
                    break outer
                }
                else {
                    messageLabel.text = "Keep guessing"
                }
            }
        }
    }
        
    func startGame() {
        brain.resetBoard()
        setUpGameButtons(v: gridView)
        messageLabel.text = "WELCOME TO BATTLESHIP.\nPLACE YOUR CARRIER\nON 5 CONSECUTIVE SQUARES."
        gameBoardBeingSet = true
    }
    
    func disableGameButtons(view: UIView) {
        for v in view.subviews {
            if let button = v as? UIButton {
                button.isEnabled = false
            }
        }
    }
    
    func enableGameButtons(view: UIView) {
        for v in view.subviews {
            if let button = v as? UIButton {
                button.isEnabled = true
            }
        }
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        startGame()
        buttonTappedCounter = 0
    }
}

