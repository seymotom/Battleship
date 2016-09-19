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
    
    required init?(coder aDecoder: NSCoder) {
        self.brain = BattleshipBrain(rows: 5, columns: 5)
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
        
        // note how the strike itself isn't updating the interface
        _ = brain.strike(atRow: r, andColumn: c)
        
        // redraw the whole board
        drawBoard()
        
        // check for win
        if brain.gameFinished() {
            messageLabel.text = "You win!"
        }
        else {
            messageLabel.text = "Keep guessing"
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
    
    func startGame() {
        brain.resetBoard()
        setUpGameButtons(v: gridView)
        messageLabel.text = "Good luck"
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        startGame()
    }
}

