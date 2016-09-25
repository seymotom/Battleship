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
        enum Ship: String {
            case carrier = "CARRIER"
            case battleship = "BATTLESHIP"
            case cruiser = "CRUISER"
            case submarine = "SUBMARINE"
            case destroyer = "DESTROYER"
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
    
    private var previousStrikes: [(Int, Int)] = []
    private var carPos: [(Int, Int)] = []
    private var batPos: [(Int, Int)] = []
    private var cruPos: [(Int, Int)] = []
    private var subPos: [(Int, Int)] = []
    private var desPos: [(Int, Int)] = []
    private var allShips: [(Int, Int)] = []
    
    init(rows: Int, columns: Int){
        self.rows = rows
        self.columns = columns
        self.coordinates = [[Coordinate]]()
        setupBoard()
    }
    
    func placeCoordinate(r: Int, c: Int, shipType: BattleshipBrain.Coordinate) {
        coordinates[r][c] = shipType
    }
    
    func setupBoard() {
        for _ in 0..<rows {
            self.coordinates.append([Coordinate](repeating: .empty(.hidden), count: columns))            
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
    
    func getCurrentSquare(r: Int, c: Int) -> Coordinate {
        return coordinates[r][c]
    }
    
    func shipSunk(ship: BattleshipBrain.Coordinate.Ship) -> Bool {
        for r in 0..<rows {
            for c in 0..<columns {
                if case .occupied(.hidden, ship) = coordinates[r][c] {
                    return false
                }
            }
        }
        return true
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
    
    //Unique ship checking function
    private func shipIsUnique(arrA: [(Int, Int)],arrB: [(Int, Int)]) -> Bool {
        var unique = true
        for a in arrA {
            for b in arrB {
                if a == b {
                    unique = false
                }
            }
        }
        return unique
    }
    
    //Ship positioning function
    private func buildShip(ofLength n: Int) -> [(Int, Int)] {
        var ship: [(Int, Int)] = []
        var start = (0, 0)
        switch Int(arc4random_uniform(UInt32(2))) {
        case 0: //horizontal
            start = ( Int(arc4random_uniform(UInt32(self.rows))), Int(arc4random_uniform(UInt32(self.rows))) )
            if start.0 % self.rows > self.rows - n {
                start.0 = start.0 - n
            }
            for i in 0..<n {
                ship.append((start.0 + i, start.1))
            }
        case 1: //verticle
            start = ( Int(arc4random_uniform(UInt32(self.rows))), Int(arc4random_uniform(UInt32(self.rows))) )
            if start.1 % self.rows > self.rows - n {
                start.1 = start.1 - n
            }
            for i in 0..<n {
                ship.append((start.0, start.1 + i))
            }
        default:
            break
        }
        return ship
    }
    
    //Unique ship positioning function
    private func buildUniqueShip(ofLength n: Int) -> [(Int, Int)] {
        var uniqueShip: [(Int, Int)] = buildShip(ofLength: n)
        var overlapping = true
        while overlapping == true {
            if shipIsUnique(arrA: allShips, arrB: uniqueShip) {
                allShips += uniqueShip
                overlapping = false
            } else {
                uniqueShip = buildShip(ofLength: n)
            }
        }
        return uniqueShip
    }
    
    func setUpP2Ships() {        
        carPos = buildShip(ofLength: 5)
        allShips += carPos
        batPos = buildUniqueShip(ofLength: 4)
        cruPos = buildUniqueShip(ofLength: 3)
        subPos = buildUniqueShip(ofLength: 3)
        desPos = buildUniqueShip(ofLength: 2)
        
        for x in carPos {
            coordinates[x.0][x.1] = BattleshipBrain.Coordinate.occupied(.hidden, .carrier)
        }
        for x in batPos {
            coordinates[x.0][x.1] = BattleshipBrain.Coordinate.occupied(.hidden, .battleship)
        }
        for x in cruPos {
            coordinates[x.0][x.1] = BattleshipBrain.Coordinate.occupied(.hidden, .cruiser)
        }
        for x in subPos {
            coordinates[x.0][x.1] = BattleshipBrain.Coordinate.occupied(.hidden, .submarine)
        }
        for x in desPos {
            coordinates[x.0][x.1] = BattleshipBrain.Coordinate.occupied(.hidden, .destroyer)
        }
    }
    
    func strikeIsUnique(xy: (Int, Int)) -> Bool {
        for strike in previousStrikes {
            if (xy.0, xy.1) == strike {
                return false
            }
        }
        return true
    }
    
    func chooseStrike() -> [Int] {
        var uniqueStrike = false
        var x = 0
        var y = 0
        while uniqueStrike == false {
            x = Int(arc4random_uniform(UInt32(self.columns)))
            y = Int(arc4random_uniform(UInt32(self.rows)))
            if strikeIsUnique(xy: (x, y)) {
                uniqueStrike = true
            }
        }
        previousStrikes.append((x, y))
        let coordArr = [x, y]
        return coordArr
    }
}
