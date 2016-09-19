//
//  BattleBrain.swift
//  Monty
//
//  Created by Jason Gresh on 9/17/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation

class BattleBrain {
    let numSquares: Int
    let numColumns: Int
    
    init(numSquares:Int, numColumns: Int){
        self.numSquares = numSquares
        self.numColumns = numColumns
        setupSquares(n: numSquares, col: numColumns)
    }
    
    fileprivate enum State: String{
        case hit = "HIT"
        case miss = "MISS"
        case car = "CARRIER"
        case bat = "BATTLESHIP"
        case cru = "CRUISER"
        case sub = "SUBMARINE"
        case des = "DESTROYER"
    }
    
    var currentShipType = ""
    
    private var carrier: [Int] = []
    private var battleship: [Int] = []
    private var cruiser: [Int] = []
    private var submarine: [Int] = []
    private var destroyer: [Int] = []
    private var allShips: [Int] = []
    
    private var squares: [State] = []
    
    //UNIQUE ARRAY CHECKING FUNCTION
    private func shipIsUnique(arrA: [Int],arrB: [Int]) -> Bool {
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
    
    //ARRAY BUILDING FUNCTIONS
    private func buildAShip(n: Int, c: Int) -> [Int] {
        var ship: [Int] = []
        var start = 0
        //random between 0 and 1 for horizontal or verticle
        switch Int(arc4random_uniform(UInt32(2))) {
        case 0: //horizontal
            //set start position dynamically on the left using modulo of the columns
            //c is the number of columns in the grid
            start = Int(arc4random_uniform(UInt32(numSquares))) + 1
            if start % c > (c - n) {
                start = start - n
            }
            for i in 0..<n {
                ship.append(start + i)
            }
        case 1: // verticle
            //set start position dynamically in the top
            start = Int(arc4random_uniform(UInt32(numSquares - (c * (n - 1))))) + 1
            for i in 0..<n {
                ship.append(start + (i * c))
            }
        default:
            break
        }
        return ship
    }
    
    private func buildAUniqueShip(length: Int, c: Int, masterShips: [Int]) -> [Int] {
        var uniqueShip: [Int] = buildAShip(n: length, c: c )
        var overlapping = true
        while overlapping == true {
            if shipIsUnique(arrA: masterShips, arrB: uniqueShip) {
                allShips += uniqueShip
                overlapping = false
            } else {
                uniqueShip = buildAShip(n: length, c: c)
            }
        }
        return uniqueShip
    }
    
    func setupSquares(n: Int, col: Int){
        squares = []
        allShips = []
        carrier = []
        battleship = []
        cruiser = []
        submarine = []
        destroyer = []
        squares = Array(repeating: .miss, count: numSquares)
        carrier = buildAShip(n: 5, c: col)
        allShips += carrier
        battleship = buildAUniqueShip(length: 4, c: col, masterShips: allShips)
        cruiser = buildAUniqueShip(length: 3, c: col, masterShips: allShips)
        submarine = buildAUniqueShip(length: 3, c: col, masterShips: allShips)
        destroyer = buildAUniqueShip(length: 2, c: col, masterShips: allShips)
        
        for spot in carrier {
            squares[spot] = .car
        }
        for spot in battleship {
            squares[spot] = .bat
        }
        for spot in cruiser {
            squares[spot] = .cru
        }
        for spot in submarine {
            squares[spot] = .sub
        }
        for spot in destroyer {
            squares[spot] = .des
        }
    }
    
    func checkSquare(_ squareIn: Int) -> Bool {
        currentShipType = squares[squareIn].rawValue
        assert(squareIn < squares.count)  //helps with debugging
        let s = squares[squareIn]
        if s == .car || s == .bat || s == .cru || s == .sub || s == .des {
            squares[squareIn] = .hit
            return true
        } else {
            return false
        }
    }
    
    func checkWin() -> Bool {
        var shipCount = 0
        for s in squares {
            if s == .car || s == .bat || s == .cru || s == .sub || s == .des {
                shipCount += 1
            }
        }
        return shipCount == 0
    }
    
    func sunkShip(ship: String) -> Bool {
        var shipLength = 0
        for s in squares {
            if s.rawValue == ship {
                shipLength += 1
            }
        }
        return shipLength == 0
    }
}
