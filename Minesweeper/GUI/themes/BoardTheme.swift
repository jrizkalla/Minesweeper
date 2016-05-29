//
//  Theme.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-09.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

/// Used by tileShape
typealias TileShapeInfo = (relation: NSLayoutRelation, multiplier: CGFloat, constant: CGFloat);

/**
    Theme for Board
 */
protocol BoardTheme {
    /**
        The owner of the theme. Will be set at initialization before any of the protocol's methods
        are called.
        Must be weak to avoid circular references
     */
    weak var owner: BoardView! { get set };
    
    // MARK: - The board
    
    /**
        Draw a tile in the specififed rectangle **without the border**.
        - Warning: the tile (and whole board) may not always be a valid board. Even though tile.realValue should not return .Hidden, it may do so in the board (see BoardView.Initializer)
        - Parameters:
            - rect: the `NSRect` to draw in. `rect` is a square if this theme `requiresSquareTiles`
            - tile: the `Board.UserTile` to draw
            - state: the state of the tile (normal, pressed, or right pressed)
            - enabled: whether or not the board view is enabled
            - cachedPaths: a bunch of cached `NSBezierPath`s. If the tile is not changed, an array of paths are given so that the theme does not have to redraw it. The array passed is the same one returned by `drawTileInRect` the last time it was called
        - Returns: an array of paths to cache (can be empty)
     */
    func drawTileInRect(rect: NSRect, tile: Board.UserTile, state: BoardView.PressState, enabled: Bool);
    /**
        Draw a border from `start` to `end`
        - Parameters:
            - width: the width of the border
            - start: the start point of the border line
            - end: the end point of the border line
     */
    func drawBorderLineWithWidth(width: CGFloat, start: CGPoint, end: CGPoint);
    
    
    // MARK: - Control area above the board
    
    
    // MARK: Positioning and dimensions
    
    /// The minimum bounds of the timerLabel. Not set if it's `null`
    var minTimerLabelBounds: NSSize? { get };
    /// The minimum bounds of the bombsLabel. Not set if it's `null`
    var minBombsLabelBounds: NSSize? { get };
    /// The minimum bounds of the resetButton. Not set if it's `null`
    var minResetButtonBounds: NSSize? { get };
    /// The height of the control box. The width is equals to the wdith of the view
    var controlBoxHeight: CGFloat { get };
    
    /// the maximum tile size. Not set if it's `null`
    var maxTileBounds: CGSize? { get };
    /// the minimum tile size. Not set if it's `null`
    var minTileBounds: CGSize? { get };
    
    /**
        Specifies the shape of a tile where width <relation>(= >=, <=) height * multiplier + constant.
        If it's nil, then no shape restrictions are imposed.
        For example, to specify square tiles, use:
     
            (relation: .Equal, multiplier: 1, constant: 0)
    */
    var tileShape: TileShapeInfo? { get };
    
    
    // MARK: making control box
    /**
        The control box is the NSView that contains the timer, bomb counter, and reset button
        Gives the theme a chance to customize the control view.
        This method should not attempt to insert anything in the view.
        It should only customize the view's appearance (background, foreground...)
        - Parameter ctrlBox: the control view to customize
     */
    func customizeControlBox(ctrlBox: NSView);
    
    
    /**
        The label that shows the time elapsed.
        It is positioned on the top left of the window.
     
        This variable is only read once. So you can compute it on the fly
     */
    var timerLabel: NSView { get };
    /**
        The label that shows the number of bombs - number of flagged tiles.
        It is positioned on the top right of the window.
     
        This variable is only read once. So you can compute it on the fly
     */
    var bombsLabel: NSView { get };
    /**
        The "Hapy Face button" (which resets the board when pressed)
        It is posisionted in the top and horizontally centered.
     
        This variable is only read once. So you can compute it on the fly
     */
    var resetButton: NSButton { get };
    
    
    /**
        Update the `timerLabel` to the correct time.
        This function gives the theme a chance to customize the time format.
        - Parameters:
            - timerLabel: the label. It is the same one obtained using `theme.timerLabel`
            - time: a time duration. Convert it to hours, minutes, seconds, and milliseconds using `BoardViewController.convertTimeDuration`
     */
    func updateTimerLabel(timerLabel: NSView, time: NSTimeInterval);
    
    /**
        Update the bombsLabel with a new value.
        - Parameters:
            - bombsLabel: the label. It is the same one obtained using `theme.bombsLabel`
            - value: the new value
     
     */
    func updateBombsLabel(bombsLabel: NSView, value: Int);
}