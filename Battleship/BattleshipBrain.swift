//
//  BattleshipBrain.swift
//  Battleship
//
//  Created by Jason Gresh on 9/18/16.
//  Copyright © 2016 C4Q. All rights reserved.
//


import Foundation

class BattleshipBrain {
    enum Coordinate {
        enum Ship {
            case carrier(Int)
            case battleship(Int)
        }
        enum State {
            case hidden, shown
        }
        case occupied(State, Ship)
        case empty(State)
        
        mutating func tryToHit() -> Bool {
            switch self {
            case .occupied(let state, let ship):
                switch state {
                case .hidden:
                    self = Coordinate.occupied(.shown, ship)
                    return true
                case .shown:
                    return true
                }
            case .empty:
                self = Coordinate.empty(.shown)
                return false
            }
        }
    }
    
    let rows: Int
    let columns: Int

    private var coordinates: [[Coordinate]]
    
    init(rows: Int, columns: Int){
        self.rows = rows
        self.columns = columns
        self.coordinates = [[Coordinate]]()
        setupBoard()
    }
    
    
    func setupBoard() {
        for r in 0..<rows {
            self.coordinates.append([Coordinate](repeating: .empty(.hidden), count: columns))
            
            // this just sets one hit per column
            coordinates[r][Int(arc4random_uniform(UInt32(columns)))] = Coordinate.occupied(.hidden, .carrier(5))
        }
    }
    
    func resetBoard() {
        self.coordinates = [[Coordinate]]()
        setupBoard()
    }
    
    subscript(i: Int, j: Int) -> Coordinate {
        return coordinates[i][j]
    }
    
    func strike(atRow r: Int, andColumn c: Int) -> Bool {
        return coordinates[r][c].tryToHit()
    }
    
    func gameFinished() -> Bool {
        for r in 0..<rows {
            for c in 0..<columns {
                // if any occupied coordinates are hidden we're not done
                if case .occupied(.hidden, _) = coordinates[r][c] {
                    return false
                }
            }
        }
        return true
    }
}
