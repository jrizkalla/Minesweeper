//
//  Theme.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-09.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

protocol BoardTheme {
    var requiresSquare: Bool { get };
    
    /**
        The owner of the theme. Will be set at initialization before any of the protocol's methods
        are called.
        Must be weak to avoid circular references
     */
    weak var owner: BoardView! { get set };
    
    /**
        Draw a tile in the specififed rectangle **without the border**.
        - Warning: the tile (and whole board) may not always be a valid board. Even though tile.realValue should not return .Hidden, it may do so in the board (see BoardView.Initializer)
        - Parameters:
            - rect: the `NSRect` to draw in
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
    
    /**
        If this theme `requiresSquare`, there might be some parts of the "background" visible
        (if the shape of the theme is not a square).
        This method gets called to draw the visible parts.
        If this theme does not `requireSquare`, then this method never gets called.
        - Parameter rect: the `NSRect` to draw
     */
    func drawBackgroundRect(rect: NSRect);
}