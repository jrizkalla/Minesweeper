//
//  BoardObserver.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Foundation

/**
    Board observers get notified when tiles change in a board
    Add and remove observers to a board using `addObserver` and `removeObserver`.
    The only reason `BoardObserver` is a `class` only protocol is to allow === to work.
 
    - SeeAlso: `Board.addObserver` and `Board.removeObserver`
 */
public protocol BoardObserver: class {
    
    /**
        Gets called when a tile gets revealed or flagged
        - Parameters:
            - x: the *x* coordinate of the tile
            - y: the *y* coordinate of the time
            - tile: a copy of the tile that changed
     */
    func tileChanged(x x: Int, y: Int, tile: Tile) -> Void;
    
    /**
        Gets called when `Board.pressTile` gets called on a hidden bomb
        - Parameters:
            - x: the *x* coordinate of the tile
            - y: the *y* coordinate of the time
     */
    func gameLost(x x:Int, y: Int) -> Void;
    
    /**
        Gets called when the last bomb is flagged
        - Parameters:
            - x: the *x* coordinate of the tile
            - y: the *y* coordinate of the time
     */
    func gameWon(x x:Int, y: Int) -> Void;
    
    /**
        Everything in the board changed
     */
    //func boardChanged() -> Void;
}