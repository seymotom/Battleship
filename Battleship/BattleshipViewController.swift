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
    
    let p1Brain: BattleshipBrain
    let p2Brain: BattleshipBrain
    
    enum gameState {
        case p1BoardBeingSet
        case p1GameBeingPlayed
        case p2BoardBeingSet
        case p2GameBeingPlayed
    }
    
    var stateOfTheGame = gameState.p1BoardBeingSet
    var buttonTappedCounter = 0
    
    required init?(coder aDecoder: NSCoder) {
        let x = 10
        self.p1Brain = BattleshipBrain(rows: x, columns: x)
        self.p2Brain = BattleshipBrain(rows: x, columns: x)
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
        let r = (sender.tag - 1) / p1Brain.columns
        let c = (sender.tag - 1) % p1Brain.columns
        buttonTappedCounter += 1
        
        switch stateOfTheGame {
        case .p1BoardBeingSet:
            sender.backgroundColor = .yellow
            sender.isEnabled = false
            switch buttonTappedCounter {
            case 0:
                messageLabel.text = "ERROR"
            case 1...5:
                p1Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .carrier))
                if buttonTappedCounter == 5 {
                    messageLabel.text = "P1 CARRIER SET.\nPLACE YOUR BATTLESHIP\nON 4 CONSECUTIVE SQUARES."
                }
            case 6...9:
                p1Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .battleship))
                if buttonTappedCounter == 9 {
                    messageLabel.text = "P1 BATTLESHIP SET.\nPLACE YOUR CRUISER\nON 3 CONSECUTIVE SQUARES."
                }
            case 10...12:
                p1Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .cruiser))
                if buttonTappedCounter == 12 {
                    messageLabel.text = "P1 CRUISER SET.\nPLACE YOUR SUBMARINE\nON 3 CONSECUTIVE SQUARES."
                }
            case 13...15:
                p1Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .submarine))
                if buttonTappedCounter == 15 {
                    messageLabel.text = "P1 SUBMARINE SET.\nPLACE YOUR DESTROYER\nON 2 CONSECUTIVE SQUARES."
                }
            case 16...17:
                p1Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .destroyer))
                if buttonTappedCounter == 17 {
                    messageLabel.text = "P1 DESTROYER SET.\nALL P1 SHIPS NOW SET\nPRESS SWITCH FOR PLAYER 2."
                    disableGameButtons(view: gridView)
                }
            default:
                break
            }

            case .p2BoardBeingSet:
            buttonLabel.setTitle("START", for: .normal)
            sender.backgroundColor = .orange
            sender.isEnabled = false
            switch buttonTappedCounter {
            case 0:
                messageLabel.text = "ERROR"
            case 1...5:
                p2Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .carrier))
                if buttonTappedCounter == 5 {
                    messageLabel.text = "P2 CARRIER SET.\nPLACE YOUR BATTLESHIP\nON 4 CONSECUTIVE SQUARES."
                }
            case 6...9:
                p2Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .battleship))
                if buttonTappedCounter == 9 {
                    messageLabel.text = "P2 BATTLESHIP SET.\nPLACE YOUR CRUISER\nON 3 CONSECUTIVE SQUARES."
                }
            case 10...12:
                p2Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .cruiser))
                if buttonTappedCounter == 12 {
                    messageLabel.text = "P2 CRUISER SET.\nPLACE YOUR SUBMARINE\nON 3 CONSECUTIVE SQUARES."
                }
            case 13...15:
                p2Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .submarine))
                if buttonTappedCounter == 15 {
                    messageLabel.text = "P2 SUBMARINE SET.\nPLACE YOUR DESTROYER\nON 2 CONSECUTIVE SQUARES."
                }
            case 16...17:
                p2Brain.placeCoordinate(r: r, c: c, shipType: .occupied(.hidden, .destroyer))
                if buttonTappedCounter == 17 {
                    messageLabel.text = "P2 DESTROYER SET.\nALL P2 SHIPS NOW SET\nPRESS START TO PLAY."
                    disableGameButtons(view: gridView)
                }
            default:
                break
            }
            
        case .p1GameBeingPlayed:
            // note how the strike itself isn't updating the interface
            _ = p2Brain.strike(atRow: r, andColumn: c)
            p2DrawBoard()
            let currentSquare = p2Brain.getCurrentSquare(r: r, c: c)
            switch currentSquare {
            case .empty(_):
                messageLabel.text = "PLAYER 1 MISSED"
            case .occupied(_, let ship):
                messageLabel.text = "PLAYER 1 HIT THE P2 \(ship.rawValue)"
            }
            if case .occupied(_, let ship) = currentSquare {
                if p2Brain.shipSunk(ship: ship) {
                    messageLabel.text = "PLAYER 1 SUNK THE P2 \(ship.rawValue)"
                }
            }
            // check for win
            if p2Brain.gameFinished() {
                messageLabel.text = "PLAYER 1 SUNK ALL P2 SHIPS.\nPLAYER 1 WINS!"
                 buttonLabel.setTitle("P2 SUCKS", for: .normal)
            }
            disableGameButtons(view: gridView)

        case .p2GameBeingPlayed:
            // note how the strike itself isn't updating the interface
            _ = p1Brain.strike(atRow: r, andColumn: c)
            p1DrawBoard()
            let currentSquare = p1Brain.getCurrentSquare(r: r, c: c)
            switch currentSquare {
            case .empty(_):
                messageLabel.text = "PLAYER 2 MISSED"
            case .occupied(_, let ship):
                messageLabel.text = "PLAYER 2 HIT THE P1 \(ship.rawValue)"
            }
            if case .occupied(_, let ship) = currentSquare {
                if p1Brain.shipSunk(ship: ship) {
                    messageLabel.text = "PLAYER 2 SUNK THE P1 \(ship.rawValue)"
                }
            }
            // check for win
            if p1Brain.gameFinished() {
                messageLabel.text = "PLAYER 2 SUNK ALL P1 SHIPS.\nPLAYER 2 WINS!"
                buttonLabel.setTitle("", for: .normal)
            }
            disableGameButtons(view: gridView)
        }
    }
    
    func p1DrawBoard() {
        for r in 0..<p1Brain.rows {
            for c in 0..<p1Brain.columns {
                // find the button by tag
                // our tag is one-based so we add 1
                if let button = gridView.viewWithTag(r * p1Brain.columns + c + 1) as? UIButton {
                    
                    // funky subscript call with two indexes ([r][c] doesn't seem to work)
                    switch p1Brain[r, c] {
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
    func p2DrawBoard() {
        for r in 0..<p2Brain.rows {
            for c in 0..<p2Brain.columns {
                // find the button by tag
                // our tag is one-based so we add 1
                if let button = gridView.viewWithTag(r * p1Brain.columns + c + 1) as? UIButton {
                    
                    // funky subscript call with two indexes ([r][c] doesn't seem to work)
                    switch p2Brain[r, c] {
                    case .empty(let state):
                        switch state {
                        case .shown:
                            button.backgroundColor = UIColor.darkGray
                        case .hidden:
                            button.backgroundColor = UIColor.cyan
                        }
                    case .occupied(let state, _):
                        switch state {
                        case .shown:
                            button.backgroundColor = UIColor.green
                        case .hidden:
                            button.backgroundColor = UIColor.cyan
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
        
        let side : CGFloat = v.bounds.size.width / CGFloat(p1Brain.rows)
        for row in 0..<p1Brain.rows {
            for col in 0..<p1Brain.columns {
                
                let rect = CGRect(origin: CGPoint(x: CGFloat(row) * side,
                                                  y: CGFloat(col) * side),
                                  size: CGSize(width: side - 1, height: side - 1))
                let button = UIButton(frame: rect)
                
                // this flattens the 2d matrix into a sequence of numbers
                // our tag is one-based so we add 1
                button.tag = row * p1Brain.columns + col + 1
                
                let letter = String(Character(UnicodeScalar(65 + row)!))
                button.setTitle("\(letter)\(col + 1)", for: UIControlState())
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                v.addSubview(button)
            }
        }
    }
    
    @IBAction func computerPlayer(_ sender: UIButton) {
//        messageLabel.text = "Ships set. CPU now playing."
//        stateOfTheGame = .p1BoardBeingSet
//        p1DrawBoard()
//        cpuPlaysTheGame()
        startGame()
        
    }
    
//    func cpuPlaysTheGame() {
//        outer: for r in 0..<p1Brain.rows {
//            inner: for c in 0..<p1Brain.columns {
//                // note how the strike itself isn't updating the interface
//                _ = p1Brain.strike(atRow: r, andColumn: c)
//                
//                // redraw the whole board
//                p1DrawBoard()
//                
//                // check for win
//                if p1Brain.gameFinished() {
//                    messageLabel.text = "CPU wins!"
//                    disableGameButtons(view: gridView)
//                    break outer
//                }
//                else {
//                    messageLabel.text = "Keep guessing"
//                }
//            }
//        }
//    }
    
    func startGame() {
        p1Brain.resetBoard()
        p2Brain.resetBoard()
        setUpGameButtons(v: gridView)
        p1DrawBoard()
        messageLabel.text = "WELCOME TO BATTLESHIP PLAYER 1.\nPLACE YOUR CARRIER\nON 5 CONSECUTIVE SQUARES."
        stateOfTheGame = .p1BoardBeingSet
        buttonTappedCounter = 0
        buttonLabel.setTitle("SWITCH", for: UIControlState())
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
    
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBAction func resetTapped(_ sender: UIButton) {
        switch stateOfTheGame {
        case .p1BoardBeingSet:
            p2DrawBoard()
            messageLabel.text = "WELCOME TO BATTLESHIP PLAYER 2.\nPLACE YOUR CARRIER\nON 5 CONSECUTIVE SQUARES."
            enableGameButtons(view: gridView)
            stateOfTheGame = .p2BoardBeingSet
            buttonLabel.setTitle("SWITCH->P1", for: UIControlState())
            buttonTappedCounter = 0
            enableGameButtons(view: gridView)
        case .p2BoardBeingSet:
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            messageLabel.text = "PLAY BATTLESHIP.\nPLAYER 1 TO FIRE."
            buttonLabel.setTitle("SWITCH->P2", for: UIControlState())
            enableGameButtons(view: gridView)
        case .p1GameBeingPlayed:
            stateOfTheGame = .p2GameBeingPlayed
            p1DrawBoard()
            enableGameButtons(view: gridView)
            buttonLabel.setTitle("SWITCH->P2", for: UIControlState())
            messageLabel.text = "PLAYER 2 TO FIRE."
        case .p2GameBeingPlayed:
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            enableGameButtons(view: gridView)
            buttonLabel.setTitle("SWITCH->P1", for: UIControlState())
            messageLabel.text = "PLAYER 1 TO FIRE."
        }
    }
}

