//
//  Board.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Foundation

/**
    Represents a minesweeper game board
    - Warning: It is recommended that all boards be less than **`100 * 100`** in size.
    For larger boards, it is also recommended that the number of bombs be at least **1 percent** of the board size.
    
    Larger board cause very deap recursion (which will probably cause a stack overflow) when an empty tile is pressed.
 */
public class Board {
    
    // MARK: - Errors
    
    enum Error: ErrorType{
        /**
            One of the Arguments is invalid
         */
        case IllegalArgument(reason: String);
    }
    
    // MARK: - Spec
    
    /**
        A way to represents the board's values (width, height, and numBombs)
        The constructor does not validate the values (to be efficient)
     */
    public struct Spec {
        public static let errorMessage = "width, height, and numBombs must be greater than 0. numBombs must be less than or equal to (width * height - 9)";
        public var width, height, numBombs: Int;
        /// - Returns: true if the values of Spec make sence and false otherwise
        public func validate() -> Bool {
            return (width > 0 && height > 0 && numBombs > 0 && (numBombs <= (width * height - 9)));
        }
    }
    
    // MARK: - UserTile
    
    /**
        A `UserTile` is a **read only** tile returned by
        `subscript(x, y)`. Aside from the values contained inside a normal tile,
        it also provides useful functions for looping on tiles around it.
     */
    public class UserTile {
        /// The *x* coordinate of the tile
        let x: Int;
        /// The *y* coordinate of the tile
        let y: Int;
        /// A read-only version of the underlying tile
        let tile: Tile;
        /// The board the tile is in
        let board: Board;
        
        /// The value of the tile. It depends on wether the tile is hidden or not
        /// - SeeAlso `Tile.value`
        var value: Tile.TileValue {
            return tile.value;
        }
        /// The real value of the tile. Does not depend on the whether it's hidden or not
        /// - SeeAlso `Tile.realValue`
        var realValue: Tile.TileValue {
            return tile.realValue;
        }
        /// Wether or not the tile is hidden
        /// - SeeAlso `tile.isHidden`
        var isHidden: Bool {
            return tile.isHidden;
        }
        /// Wether or not the tile is flagged
        /// - SeeAlso `tile.isFlagged`
        var isFlagged: Bool {
            return tile.isFlagged;
        }
        /// The number of neighbours flagged (`isFlagged`)
        /// - SeeAlso `board.numNeighboursFlagged`
        var numNeighboursFlagged: Int {
            return board.numNeighboursFlagged(x: x, y: y);
        }
        
        // MARK: Methods
        
        // Creates a read only user tile
        private init(x: Int, y: Int, tile: Tile, board: Board){
            self.x = x;
            self.y = y;
            self.tile = tile;
            self.board = board;
        }
        
        /**
            Applies `body` to all neighbours of the current tile
            - Parameter body: the function to apply to all neighbours
            - SeeAlso: `body.forAllNeighbours`
         */
        public func forAllNeighbours(body: (Int, Int, Tile) -> Void) {
            board.forAllNeighbours(x: x, y: y, body);
        }
    }
    
    // MARK:- Static Methods
    /**
        - Todo: implement
        - Warning: <span style="color: red">not implemented yet. Still needs the solver to be working</span>
        - returns <span style="color">an empty board</span>
     */
    public class func createBoard(width: Int, height: Int, numBombs: Int, x:Int, y:Int) -> Board {
        let board = Board(width: width, height: height, numBombs: numBombs);
        return board;
    }
    
    /**
        Creates an empty board (all the tiles are hidden)
        - Parameters:
            - width: the width of the board. Must be greater than 0
            - height: the height of the board. Must be greater than 0
        - Returns: a board in an invalid state. **Attempts to pressTile in the returned board will probably crash**.
        - Throws: `Error.IllegalArgument` if some of the preconditions are not met
     */
    public class func createEmptyBoard(width: Int, height: Int) throws -> Board {
        guard height > 0 && width > 0 else {
            throw Error.IllegalArgument(reason: "width and height must be greater than 0");
        }
        
        return Board(width: width, height: height, numBombs: 0);
    }
    
    /**
        Creates a random board
        - Parameters:
            - width: the width of the board
            - height: the height of the board
            - numBombs: the number of bombs. Must be less than `(width * height) - 9` and more than 0
            - x: the x coordinate of the starting point (that does not have any bombs)
            - y: the y coordinate of the starting point (that does not have any bombs)
        - Returns: a fully initialized board
        - Throws: `Error.IllegalArgument` if some of the preconditions are not met
     */
    public class func createRandomBoard(width: Int, height: Int, numBombs: Int, x: Int, y: Int) throws -> Board {
        guard width >= 3 && height >= 3 && (numBombs <= (width * height - 3 * 3)) else {
            throw Error.IllegalArgument(reason: "The board is too small or there are too many bombs");
        }
        
        var possiblePoints = [NSPoint]();
        for i in 0..<width {
            for j in 0..<height {
                if (i >= x - 1 && i <= x + 1) && (j >= y - 1 && j <= y + 1) {
                    // ignore the 3 by 3 square around (x, y)
                    continue;
                }
                possiblePoints.append(NSPoint(x: i, y: j));
            }
        }
        
        // shuffle the array of possible points
        for i in 0..<possiblePoints.count {
            // replace possiblePoints[i] with something random
            let j = Int(arc4random_uniform(UInt32(possiblePoints.count)));
            let temp = possiblePoints[i];
            possiblePoints[i] = possiblePoints[j];
            possiblePoints[j] = temp;
        }
        
        // trim the size to numBombs;
        if numBombs < possiblePoints.count {
            possiblePoints.removeRange(numBombs ..< possiblePoints.count);
        }
        
        let board = Board(width: width, height: height, numBombs: numBombs);
        
        // place the bombs
        for i in 0..<possiblePoints.count {
            let pt = possiblePoints[i];
            board.board[Int(pt.x)][Int(pt.y)] = Tile(value: .Bomb);
        }
        
        // And place everything else
        for x in 0..<width {
            for y in 0..<height {
                if board.board[x][y].realValue != .Hidden {
                    continue;
                }
                
                var numBombsAround = 0;
                board.forAllNeighbours(x: x, y: y) {
                    if $2.realValue == .Bomb {
                        numBombsAround += 1;
                    }
                }
                assert(numBombsAround < 9);
                
                if numBombsAround == 0 {
                    board.board[x][y] = Tile(value: .Blank);
                } else {
                    board.board[x][y] = Tile(value: .Num(numBombsAround));
                    //print("Setting (\(x), \(y)) to \(board.board[x][y])");
                }
            }
        }
        
        return board;
    }
    
    
    // MARK:- members
    
    /// The board looks like this:
    /// ```
    /// _  _  _
    /// +  +  +
    /// +  +  +
    /// +  +  +
    /// -  -  -
    /// ```
    private var board: [[Tile]];
    /// the total number of bombs in the board
    public private(set) var numBombs = 0;
    /// the number of correctly flagged tiles
    public private(set) var numFlagged = 0;
    /// the number of incorrectly flagged tile
    public private(set) var numFlaggedWrong = 0;
    /// the number of non-bombs revealed
    public private(set) var numRevealed = 0;
    /// the number of bombs revealed. If it's more than 1, the game is lost
    public private(set) var numBombsRevealed = 0;
    private var observers = [BoardObserver]();
    
    // MARK: Public members
    
    /// the width of the board
    public var width: Int {
        return board.count;
    }
    
    /// the height of the board
    public var height: Int {
        return board[0].count;
    }
    
    /**
        Returns a **copy** of the tile at *(x, y)* as a `UserTile`
        - Parameters:
            - x: the x coordinate
            - y: the y coordinate
     */
    public subscript(x: Int, y: Int) -> UserTile {
        return UserTile(x: x, y: y, tile: board[x][y], board: self);
    }
    
    // MARK:- Ctor
    // It's private because it creates an inconsistent object and does
    // not do any kind of error checking
    private init(width: Int, height: Int, numBombs: Int) {
        board = [[Tile]]();
        for x in 0..<width {
            board.append([Tile]());
            for _ in 0..<height {
                board[x].append(Tile(value: .Hidden));
            }
        }
        
        self.numBombs = numBombs;
    }
    
    // MARK: Observers
    public func addObserver(observer: BoardObserver) {
        observers.append(observer);
    }
    public func removeObserver(observer: BoardObserver) {
        if let i = observers.indexOf({ $0 === observer }) {
            observers.removeAtIndex(i);
        }
    }
    
    
    /**
        Flag the tile at *(x, y)*.<br>
        Flagging a revealed tile does nothing<br>
        Flagging a flagged tile un-flags it<br>
        If all the bombs are flagged and all other tiles are revealed a `gameWon` message is sent to all observers
        - Parameter x: x the x coordinate
        - Parameter y: y the y coordinate
     */
    public func flagTile(x x: Int, y: Int) throws {
        guard (x >= 0 && x < width) && (y >= 0 && y < height) else {
            throw Error.IllegalArgument(reason: "Illegal values of x and/or y");
        }
        
        if board[x][y].isHidden && !board[x][y].isFlagged {
            // flag it
            board[x][y].isFlagged = true;
            if board[x][y].realValue == Tile.TileValue.Bomb {
                numFlagged += 1;
            } else {
                numFlaggedWrong += 1;
            }
            // Tell everyone
            observers.forEach() {
                $0.tileChanged(x: x, y: y, tile: board[x][y]);
            }
        } else if board[x][y].isFlagged {
            // un-flag it
            board[x][y].isFlagged = false;
            if board[x][y].realValue == .Bomb {
                numFlagged -= 1;
            } else {
                numFlaggedWrong -= 1;
            }
            // Tell everyone
            observers.forEach() {
                $0.tileChanged(x: x, y: y, tile: board[x][y]);
            }
        }
    }
    
    
    /**
        Press the tile at (x, y).<br>
        If the tile is blank or flagged nothing happens.<br>
        If the tile is a number with all of it's bombs flagged around it (even if they're flagged wrong), all the un-flagged surroundings are pressed.<br>
        If the tile is hidden, it's revealed. If it was a bomb a `gameLost` message is sent to all observers.<br>
        If the tile was blank (and hidden) then all the surroundings are revealed.<br>
        If all tiles that aren't bombs are revealed a `gameWon` message is sent to all observers.<br>
        - Parameter x: the x coordinate of the tile
        - Parameter y: the y coordinate of the tile
     */
    public func pressTile(x x: Int, y: Int) throws {
        guard (x >= 0 && x < width) && (y >= 0 && y < height) else {
            throw Error.IllegalArgument(reason: "Illegal values of x and/or y");
        }
        
        
        if board[x][y].isHidden && !board[x][y].isFlagged && board[x][y].realValue == .Bomb {
            // Hidden, unflagged bomb
            board[x][y].isHidden = false;
            numBombsRevealed += 1;
            observers.forEach() { $0.tileChanged(x: x, y: y, tile: board[x][y]); };
            observers.forEach() { $0.gameLost(x: x, y: y); };
            return;
        } else if board[x][y].isHidden && !board[x][y].isFlagged && board[x][y].realValue == .Blank {
            // Hidden, unflagged blank
            // We have to press all the neighbours of (x, y).
            // Unfortunately, for large boards with few tiles (200 * 200 with 1% bombs for example)
            // this leads to a LOT of recursion and eventually a stack overflow (oh no!)
            
            // So, instead, we're going to do recursion in a stupid but efficient way
            // we're manually going to keep a stack...
            var stack = [(x: Int, y: Int)]();
            stack.append((x: x, y: y));
            
            var maxStackSize = 0;
            while stack.count > 0 {
                let (x, y) = stack.removeFirst();
                board[x][y].isHidden = false;
                numRevealed += 1;
                observers.forEach(){ $0.tileChanged(x: x, y: y, tile: board[x][y]) };
                if numRevealed == (width * height - numBombs) {
                    // game won
                    observers.forEach() { $0.gameWon(x: x, y: y); };
                }
                // reveal all the surrounding
                if board[x][y].realValue == .Blank {
                    self.forAllNeighbours(x: x, y: y) {
                        if $2.isHidden {
                            self.board[$0][$1].isHidden = false;
                            stack.append((x: $0, y: $1));
                        }
                    }
                }
                
                if stack.count > maxStackSize {
                    maxStackSize = stack.count
                }
            }
            
            print("Max stack size: \(maxStackSize)");
        } else if board[x][y].isHidden && !board[x][y].isFlagged { // Just a number or blank tile
            // hidden, unflagged number
            board[x][y].isHidden = false;
            numRevealed += 1;
            observers.forEach() { $0.tileChanged(x: x, y: y, tile: board[x][y]); };
            if numRevealed == (width * height - numBombs) { // game won
                observers.forEach() { $0.gameWon(x: x, y: y); };
            }
        } else if !board[x][y].isHidden && board[x][y].realValue.get() >= 1 {
            print("Pressing unhidden number");
            // unhidden number. See if we can reveal any neighbours
            let numBombs = numNeighboursFlagged(x: x, y: y);
            if numBombs - board[x][y].realValue.get() == 0 {
                // reveal the right ones
                forAllNeighbours(x: x, y: y) {
                    if $2.isHidden && !$2.isFlagged {
                        try! self.pressTile(x: $0, y: $1);
                    }
                }
            }
        }
    }
    
    
    // MARK: Useful methods
    
    /**
        Applies `body` to all the neighbours of (x, y)
        - Parameters:
            - x: the x coordinate
            - y: the y coordinate
            - body: the function to apply. Has the following signature `(x, y, [Tile at x, y]) -> Void`
     */
    func forAllNeighbours(x x: Int, y: Int, _ body: (Int, Int, Tile) -> Void) {
        let width = self.width;
        let height = self.height;
        
        for i in (x-1)...(x+1) {
            if i < 0 || i >= width {
                continue;
            }
            for j in (y-1)...(y+1){
                if j < 0 || j >= height {
                    continue;
                }
                
                if i == x && j == y {
                    continue;
                }
                
                body(i, j, board[i][j]);
            }
        }
    }
    
    /**
        Applies `body` on all tiles in the board
        - Parameter body: the function to apply
     */
    func forEach (body: (Int, Int, UserTile) -> Void){
        for x in 0..<self.width {
            for y in 0..<self.height {
                body(x, y, self[x, y]);
            }
        }
    }
    
    /**
        Returns the number of tiles flagged around *(x, y)*
        - Parameters:
            - x: the *x* coordinate
            - y: the *y* coordinate
     */
    func numNeighboursFlagged(x x: Int, y: Int) -> Int{
        var numFlagged = 0;
        forAllNeighbours(x: x, y: y) {
            if $2.isFlagged {
                numFlagged += 1;
            }
        }
        return numFlagged;
    }
}
