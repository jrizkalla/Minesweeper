//
//  BoardView.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-08.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa


@IBDesignable
class BoardView: NSView, BoardObserver {
    
    /// Used to tell a `BoardTheme` the state of a tile
    enum PressState {
        /// Normal state (notPressed)
        case notPressed;
        /// pressed (clicked)
        case pressed;
        /// right clicked
        case rightPressed;
    }
    
    /// The board this view draws
    var board: Board? = nil {
        didSet {
            if let b = oldValue {
                b.removeObserver(self);
            }
            board?.addObserver(self);
        }
    }
    
    /// The theme that draws the tiles (and other stuff)
    lazy var theme: SimpleTheme = SimpleTheme(); // make it lazy just in case it changes before a draw
    
    /// The width of all the tiles (when drawn)
    var cellWidth: CGFloat {
        if let board = board {
            return CGFloat(self.bounds.width) / CGFloat(board.width)
        } else {
            return 0;
        }
    }
    /// The height of all the tiles (when drawn)
    var cellHeight: CGFloat {
        if let board = board {
            return CGFloat(self.bounds.height) / CGFloat(board.height);
        } else {
            return 0;
        }
    }
    
    // Used to mark where the user presses (before releasing the mouse)
    var mouseDownPoint: NSPoint? = nil;
    // Whether the click was right or left
    var mouseDownRight: Bool = false;
    @IBInspectable var enabled: Bool = true{
        didSet {
            self.needsDisplay = true;
        }
    }
    
    /// Divides the board and tells the theme to draw the rects
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        //NSLog("Dirty rect:");
        //NSLog("(\(dirtyRect.origin.x), \(dirtyRect.origin.y))");
        //NSLog("Width: \(dirtyRect.width), height: \(dirtyRect.height)");
        //NSLog("CellWidth: \(self.cellWidth), Cellheight: \(self.cellHeight)");
        
        if let board = self.board {
            // Draw the board
            let cellWidth = self.cellWidth;
            let cellHeight = self.cellHeight;
            
            var rect = NSRect(x: 0, y: 0, width: cellWidth, height: cellHeight);
            
            // Figure out what tiles need to be drawn (based on dirtyRect)
            let xRange = (start: Int(dirtyRect.origin.x/cellWidth),
                     end: Int((dirtyRect.origin.x + dirtyRect.size.width)/cellWidth));
            let yRange = (start: Int(dirtyRect.origin.y/cellWidth),
                     end: Int((dirtyRect.origin.y + dirtyRect.size.height)/cellHeight));
            
            //NSLog("(\(xRange.start), \(yRange.end))      (\(xRange.end), \(yRange.end))");
            //NSLog("(\(xRange.start), \(yRange.start))      (\(xRange.end), \(yRange.start))");
            //NSLog("-------------------------------------------");
            
            for x in xRange.start...xRange.end {
                for y in yRange.start...yRange.end {
                    // Skip stuff out of range
                    if x < 0 || x >= board.width ||
                        y < 0 || y >= board.height {
                        continue;
                    }
                    rect.origin.x = CGFloat(x) * cellWidth;
                    rect.origin.y = CGFloat(y) * cellHeight;
                    
                    var state = BoardView.PressState.notPressed;
                    if let m = self.mouseDownPoint {
                        if Int(m.x) == x && Int(m.y) == y {
                            state = self.mouseDownRight ? .rightPressed : .pressed;
                        }
                    }
                    theme.drawTileInRect(rect, tile: board[x, y], state: state, enabled: self.enabled);
                }
            }
            
            // draw the borders
            var start = CGPoint(x: 0, y: 0);
            var end = CGPoint(x: 0, y: self.bounds.height);
            for x in 0..<board.height+1 {
                start.x = CGFloat(x) * cellWidth;
                end.x = CGFloat(x) * cellWidth;
                theme.drawBorderLineWithWidth(1, start: start, end: end);
            }
            
            start.x = 0;
            end.x = self.bounds.width;
            for y in 0..<board.width+1 {
                start.y = CGFloat(y) * cellHeight;
                end.y = CGFloat(y) * cellHeight;
                theme.drawBorderLineWithWidth(1, start: start, end: end);
            }
        }
    }
    
    // MARK: Handling events
    
    override func mouseDown(theEvent: NSEvent) {
        if !enabled {
            return;
        }
        // where exactly?
        let cellWidth = self.cellWidth;
        let cellHeight = self.cellHeight;
        
        let pt = self.convertPoint(theEvent.locationInWindow, fromView: nil);
        mouseDownPoint = NSPoint(x: pt.x/cellWidth, y:pt.y/cellHeight);
        mouseDownRight = false;
        
        // mark the tile as dirty
        setNeedsDisplayInTile(x: Int(mouseDownPoint!.x), y: Int(mouseDownPoint!.y));
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        if !enabled {
            return;
        }
        self.mouseDown(theEvent);
        mouseDownRight = true;
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !enabled || mouseDownPoint == nil {
            return;
        }
        let pt = self.convertPoint(theEvent.locationInWindow, fromView: nil);
        let mouseUpPoint = NSPoint(x: pt.x/cellWidth, y:pt.y/cellHeight);
        if mouseUpPoint.x == mouseDownPoint!.x && mouseUpPoint.y == mouseDownPoint!.y {
            try! board?.pressTile(x: Int(mouseUpPoint.x), y: Int(mouseUpPoint.y));
        }
        setNeedsDisplayInTile(x: Int(mouseDownPoint!.x), y: Int(mouseDownPoint!.y));
        mouseDownPoint = nil;
    }
    
    override func rightMouseUp(theEvent: NSEvent) {
        if !enabled || mouseDownPoint == nil {
            return;
        }
        let pt = self.convertPoint(theEvent.locationInWindow, fromView: nil);
        let mouseUpPoint = NSPoint(x: pt.x/cellWidth, y:pt.y/cellHeight);
        if mouseUpPoint.x == mouseDownPoint!.x && mouseUpPoint.y == mouseDownPoint!.y {
            try! board?.flagTile(x: Int(mouseUpPoint.x), y: Int(mouseUpPoint.y));
        }
        setNeedsDisplayInTile(x: Int(mouseDownPoint!.x), y: Int(mouseDownPoint!.y));
        mouseDownPoint = nil;
    }
    
    // MARK: - Board observer methods

    func tileChanged(x x: Int, y: Int, tile: Tile) {
        setNeedsDisplayInTile(x: x, y: y);
    }
    
    func gameLost(x x:Int, y: Int) {
        self.enabled = false;
    }
    
    func gameWon(x x:Int, y: Int) {
        self.enabled = false;
    }

    
    // MARK: Useful methods
    /**
        Sets the area of a tile to dirty
        - Parameter x: the *x* coordinate of the tile
        - Parameter y: the *y* coordinate of the tile
     */
    func setNeedsDisplayInTile(x x: Int, y: Int) {
//        self.needsDisplay = true;
        let cellWidth = self.cellWidth;
        let cellHeight = self.cellHeight;
        // The -1 and +2 s are for rounding errors
        self.setNeedsDisplayInRect(NSRect(x: CGFloat(x) * cellWidth-1, y: CGFloat(y) * cellHeight-1, width: cellWidth+2, height: cellHeight+2));
    }

    
    // MARK: - Userful class methods
    
    /**
        Returns a font that fits inside width and height
        - Parameters:
            - str: the string to fit
            - width: the width of the area
            - height: the height of the area
        - Returns: the system font that fits inside (width * height)
     */
    class func fontForString(str: String, width: CGFloat, height: CGFloat) -> NSFont {
        // do a binary search for the font that fits in (width, height)
        let nsstr = str as NSString;
        
        // Do a binary search
        var maxSize = CGFloat(100);
        var minSize = CGFloat(1);
        
        while (maxSize - minSize) > 1 {
            let middle = minSize + ((maxSize - minSize)/2);
            let font = NSFont.systemFontOfSize(middle);
            let rect = nsstr.boundingRectWithSize(NSSize(width: 10000000, height: 1000000),
                                                  options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                  attributes: [NSFontAttributeName: font]);
            
            if rect.width > width || rect.height > height {
                // bigger. Need to make it smaller
                maxSize = middle;
            } else {
                minSize = middle;
            }
        }
     
        return NSFont.systemFontOfSize(minSize);
    }
    
}
