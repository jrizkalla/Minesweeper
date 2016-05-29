//
//  Tile.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Foundation


/**
    A Tile in a Minesweeper board
 */
public struct Tile {
    
    /// The value of the Tile
    public enum TileValue: Equatable {
        /// A bomb
        case Bomb;
        /// A blank
        case Blank;
        /// A number (has a parameter from 1 to 9 inclusive)
        case Num(Int);
        /// Not a valid storage type. But may be returned by `value`
        case Hidden;
        /// Not a valid storage type. But may be returned by `value`
        case Flagged;
        
        /**
            - Returns: a number for the enum
            where:
         
            - `1...9` is a tile number
            - `0` is a blank
            - `-1` is a bomb
            - `-10` is hidden
            - `-20` is flagged
         */
        func get() -> Int {
            switch self {
            case .Num(let num):
                return num;
            case .Blank:
                return 0;
            case .Bomb:
                return -1;
            case .Hidden:
                return -10;
            case .Flagged:
                return -20;
            }
        }
    }
    
    /// The real value of a tile (regardless of `isHidden` or `isFlagged`)
    public private(set) var realValue: TileValue = .Blank;
    /// Whether or not the tile is hidden
    public var isHidden: Bool = true;
    /// Whether or not the tile is flagged
    public var isFlagged: Bool = false;
    
    /**
        The value of the tile.
     
        - If it's hidden and flagged, the value is `.Flagged`
        - If it's just hidden, the value is `.Hidden`
        - Otherwise, the value is `realValue`
     */
    public var value: TileValue {
        get {
            if isHidden {
                if isFlagged {
                    return .Flagged;
                } else {
                    return .Hidden;
                }
            } else {
                return realValue;
            }
        }
        set {
            switch(newValue){
            case .Num(let num):
                if num > 0 && num < 9 {
                    realValue = newValue;
                } else {
                    realValue = .Blank;
                }
            default:
                realValue = newValue;
            }
        }
    }
    
    /**
        Creates a new Tile
        - Parameters:
            - value: the value of the tile
            - isHidden: default = `true`
            - isFlagged: default = `false`
     */
    public init(value: TileValue, isHidden: Bool = true, isFlagged:Bool = false){
        self.value = value;
        self.isHidden = isHidden;
        self.isFlagged = isFlagged;
    }
}

/**
    Compares two Tile Values.<br>
    Two tile values are the same if:
    - They are both `.num`s with the same values
    - They are both any other value than `.Num`
 */
public func ==(lhs: Tile.TileValue, rhs: Tile.TileValue) -> Bool {
    switch (lhs, rhs){
    case (.Num(let a), .Num(let b)) where a == b:
        fallthrough;
    case (.Bomb, .Bomb):
        fallthrough;
    case (.Blank, .Blank):
        fallthrough;
    case (.Hidden, .Hidden):
        return true;
    default:
        return false;
    }
}