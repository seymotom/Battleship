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
    
    var p1Brain: BattleshipBrain
    var p2Brain: BattleshipBrain
    
    enum GameState {
        enum UserOrCpu {
            case user
            case cpu
        }
        case p1BoardBeingSet
        case p1GameBeingPlayed
        case p2BoardBeingSet(UserOrCpu)
        case p2GameBeingPlayed(UserOrCpu)
        case gameOver
    }
    
    var stateOfTheGame = GameState.p1BoardBeingSet
    var buttonTappedCounter = 0
    var cpuIsPlaying = false
    
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
        setUpPlayerSettings()
        setUpPlayerSettings()
        let x = UIButton()
        resetGame(x)
        //startGame()
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
                    messageLabel.text = "P1 DESTROYER SET.\nALL P1 SHIPS NOW SET.\nPRESS SWITCH FOR PLAYER 2."
                    disableGameButtons(view: gridView)
                    if cpuIsPlaying {
                        messageLabel.text = "P1 DESTROYER SET.\nALL P1 SHIPS NOW SET. PRESS START TO PLAY."
                        startSwitchLabel.setTitle("START", for: .normal)
                    }
                }
            default:
                break
            }

        case .p2BoardBeingSet(.user):
            startSwitchLabel.setTitle("START", for: .normal)
            sender.backgroundColor = .yellow
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
                    messageLabel.text = "P2 DESTROYER SET.\nALL P2 SHIPS NOW SET.\nPRESS START TO PLAY."
                    disableGameButtons(view: gridView)
                }
            default:
                break
            }
            
        case .p2BoardBeingSet(.cpu):
            break
            
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
                stateOfTheGame = .gameOver
                messageLabel.text = "PLAYER 1 SUNK ALL P2 SHIPS.\nPLAYER 1 WINS!"
                startSwitchLabel.setTitle("", for: .normal)
                messageLabel.backgroundColor = .darkGray
                messageLabel.textColor = .white

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
                stateOfTheGame = .gameOver
                messageLabel.text = "PLAYER 2 SUNK ALL P1 SHIPS.\nPLAYER 2 WINS!"
                messageLabel.backgroundColor = .darkGray
                messageLabel.textColor = .white
                startSwitchLabel.setTitle("", for: .normal)
            }
            disableGameButtons(view: gridView)
            
        case .gameOver:
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
                            button.backgroundColor = UIColor.orange
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
                
                let rect = CGRect(origin: CGPoint(x: CGFloat(row) * side, y: CGFloat(col) * side), size: CGSize(width: side - 1, height: side - 1))
                let button = UIButton(frame: rect)
                
                // this flattens the 2d matrix into a sequence of numbers
                // our tag is one-based so we add 1
                button.tag = row * p1Brain.columns + col + 1
                
                let letter = String(Character(UnicodeScalar(65 + row)!))
                button.setTitle("\(letter)\(col + 1)", for: UIControlState())
                if p1Brain.rows == 12 {
                    button.titleLabel?.font = UIFont(name: "System-Thin", size: 4.0)
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                }
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                v.addSubview(button)
            }
        }
    }
    
    func setUpPlayerSettings() {
        for v in gridView.subviews {
            v.removeFromSuperview()
        }
        messageLabel.text = ""
        startSwitchLabel.isHidden = true
        let butWidth: CGFloat = gridView.bounds.size.width - 8
        let butHeight: CGFloat = (gridView.bounds.size.height / 2) - 8
        
        for i in 0...1 {
            let j = CGFloat(i)
            let thisFrame = CGRect(origin: CGPoint(x: 4 , y: (j * (butHeight + 8)) + 4), size: CGSize(width: butWidth, height: butHeight))
            let button = UIButton(frame: thisFrame)
            button.tag = i + 1
            switch button.tag {
            case 1:
                button.setTitle("Player 1 vs. Computer", for: .normal)
                button.backgroundColor = UIColor.green
            case 2:
                button.setTitle("Player 1 vs. Player 2", for: .normal)
                button.backgroundColor = UIColor.blue
            default:
                break
            }
            button.addTarget(self, action: #selector(playerButtonTapped), for: .touchUpInside)
            gridView.addSubview(button)
        }
    }
    
    func setUpGridSettings() {
        for v in gridView.subviews {
            v.removeFromSuperview()
        }
        let butWidth: CGFloat = gridView.bounds.size.width - 8
        let butHeight: CGFloat = (gridView.bounds.size.height / 3) - 8
        
        for i in 0...2 {
            let j = CGFloat(i)
            let thisFrame = CGRect(origin: CGPoint(x: 4 , y: (j * (butHeight + 8)) + 4), size: CGSize(width: butWidth, height: butHeight))
            let button = UIButton(frame: thisFrame)
            button.tag = i + 1
            switch button.tag {
            case 1:
                button.setTitle("Easy - 8x8", for: .normal)
                button.backgroundColor = UIColor.yellow
            case 2:
                button.setTitle("Medium - 10x10", for: .normal)
                button.backgroundColor = UIColor.orange
            case 3:
                button.setTitle("Hard - 12x12", for: .normal)
                button.backgroundColor = UIColor.red
            default:
                break
            }
            button.addTarget(self, action: #selector(gridSizeButtonTapped), for: .touchUpInside)
            gridView.addSubview(button)
        }
    }
    
    func playerButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            setUpGridSettings()
            cpuIsPlaying = true
        case 2:
            setUpGridSettings()
        default:
            break
        }
    }
    
    func gridSizeButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            self.p1Brain = BattleshipBrain(rows: 8, columns: 8)
            self.p2Brain = BattleshipBrain(rows: 8, columns: 8)
        case 2:
            self.p1Brain = BattleshipBrain(rows: 10, columns: 10)
            self.p2Brain = BattleshipBrain(rows: 10, columns: 10)
        case 3:
            self.p1Brain = BattleshipBrain(rows: 12, columns: 12)
            self.p2Brain = BattleshipBrain(rows: 12, columns: 12)
        default:
            break
        }
        startGame()
    }
    
    @IBAction func resetGame(_ sender: UIButton) {
        setUpPlayerSettings()
    }
    
    func startGame() {
        p1Brain.resetBoard()
        p2Brain.resetBoard()
        setUpGameButtons(v: gridView)
        p1DrawBoard()
        messageLabel.text = "WELCOME TO BATTLESHIP PLAYER 1.\nPLACE YOUR CARRIER\nON 5 CONSECUTIVE SQUARES."
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = .darkGray

        stateOfTheGame = .p1BoardBeingSet
        buttonTappedCounter = 0
        startSwitchLabel.isHidden = false
        startSwitchLabel.setTitle("SWITCH", for: .normal)
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
    
    @IBOutlet weak var startSwitchLabel: UIButton!
    
    @IBAction func startSwitchTapped(_ sender: UIButton) {
        switch stateOfTheGame {
        case .p1BoardBeingSet:
            if cpuIsPlaying {
                disableGameButtons(view: gridView)
                stateOfTheGame = .p2BoardBeingSet(.cpu)
                p2Brain.setUpP2Ships()
                messageLabel.text = "'' I have positioned my ships\nPress START to play me fool. ''"
                startSwitchLabel.setTitle("START", for: .normal)
            } else {
                p2DrawBoard()
                messageLabel.text = "WELCOME TO BATTLESHIP PLAYER 2.\nPLACE YOUR CARRIER\nON 5 CONSECUTIVE SQUARES."
                enableGameButtons(view: gridView)
                stateOfTheGame = .p2BoardBeingSet(.user)
                startSwitchLabel.setTitle("SWITCH->P1", for: .normal)
                buttonTappedCounter = 0
                enableGameButtons(view: gridView)
            }
            
        case .p2BoardBeingSet(.user):
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            messageLabel.text = "PLAY BATTLESHIP.\nPLAYER 1 TO FIRE."
            startSwitchLabel.setTitle("SWITCH->P2", for: .normal)
            enableGameButtons(view: gridView)
            
        case .p1GameBeingPlayed:
            if cpuIsPlaying {
                stateOfTheGame = .p2GameBeingPlayed(.cpu)
                let rAndC = p2Brain.chooseStrike()
                let r = rAndC[0]
                let c = rAndC[1]
                let letter = String(Character(UnicodeScalar(65 + r)!))
                _ = p1Brain.strike(atRow: r, andColumn: c)
                let currentSquare = p1Brain.getCurrentSquare(r: r, c: c)
                switch currentSquare {
                case .empty(_):
                    messageLabel.text = "'' \(letter), \(c + 1) ''\nPLAYER 2 MISSED\n'' Bollocks! '' 😠"
                case .occupied(_, let ship):
                    messageLabel.text = "'' \(letter), \(c + 1) ''\nPLAYER 2 HIT THE P1 \(ship.rawValue)\n'' Booyah! '' 😊"
                }
                if case .occupied(_, let ship) = currentSquare {
                    if p1Brain.shipSunk(ship: ship) {
                        messageLabel.text = "'' \(letter), \(c + 1) ''\nPLAYER 2 SUNK THE P1 \(ship.rawValue)\n'' In your motherfloating face!!! '' 😈"
                    }
                }
                if p1Brain.gameFinished() {
                    stateOfTheGame = .gameOver
                    messageLabel.text = "'' \(letter), \(c + 1) ''\nPLAYER 2 SUNK ALL P1 SHIPS.\nPLAYER 2 WINS!\n'' I win. You sunking suck! '' 😃"
                    startSwitchLabel.setTitle("", for: .normal)
                    messageLabel.backgroundColor = .darkGray
                    messageLabel.textColor = .white

                }
                disableGameButtons(view: gridView)
            } else {
                stateOfTheGame = .p2GameBeingPlayed(.user)
                enableGameButtons(view: gridView)
                startSwitchLabel.setTitle("SWITCH->P2", for: .normal)
                messageLabel.text = "PLAYER 2 TO FIRE."
            }
            p1DrawBoard()
            startSwitchLabel.setTitle("SWITCH->P2", for: .normal)
            
        case .p2GameBeingPlayed(.user):
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            enableGameButtons(view: gridView)
            startSwitchLabel.setTitle("SWITCH->P1", for: UIControlState())
            messageLabel.text = "PLAYER 1 TO FIRE."
            
        case .p2BoardBeingSet(.cpu):
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            messageLabel.text = "PLAY BATTLESHIP.\nPLAYER 1 TO FIRE ON CPU\n'' Good luck loser. ''."
            startSwitchLabel.setTitle("SWITCH->P2", for: UIControlState())
            enableGameButtons(view: gridView)
            
        case .p2GameBeingPlayed(.cpu):
            stateOfTheGame = .p1GameBeingPlayed
            p2DrawBoard()
            enableGameButtons(view: gridView)
            startSwitchLabel.setTitle("SWITCH->P1", for: UIControlState())
            messageLabel.text = "PLAYER 1 TO FIRE."
        
        case .gameOver:
            break

        }
    }
}

