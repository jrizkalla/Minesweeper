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
    
    
    // MARK: Properties
    
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
    // make it lazy just in case it changes before a draw
    var theme: BoardTheme = SimpleTheme() {
        didSet {
            theme.owner = self;
            assert(!theme.requiresSquare);
        }
    }
    
    /// The width of all the tiles (when drawn)
    var cellWidth: CGFloat {
        if let board = (self.board ?? self.initializer?.board) {
            return CGFloat(self.bounds.width) / CGFloat(board.width)
        } else {
            return 0;
        }
    }
    /// The height of all the tiles (when drawn)
    var cellHeight: CGFloat {
        if let board = (self.board ?? self.initializer?.board) {
            return CGFloat(self.bounds.height) / CGFloat(board.height);
        } else {
            return 0;
        }
    }
    
    /// If false, the board is not clickable AND it looks different
    /// (SimpleTheme just draws a semi trasparent gray rectangle over all tiles)
    @IBInspectable var enabled: Bool = true{
        didSet {
            self.needsDisplay = true;
        }
    }
    
    /// The same as enabled but does not change the appearance at all
    @IBInspectable var clickable: Bool = true;
    
    /// The width of the borders between cells
    @IBInspectable var borderWidth: CGFloat = 1;
    
    
    /**
        The board view can be in a diffirent state than usual.
        It can be initalizing. An initializing board view does not have
        a board *but* it still pretends it does. It fills board with a completely
        empty board. But when the user presses any tile, a new board is generated
        and the board view goes back to normal state (and initializer is set to nil)
    */
    struct Initializer {
        let board: Board;
        let numBombs: Int;
        let boardCreator: (Int, Int, Int, Int, Int) -> Board;
        
        /**
            Creates a new Initializer
            - Parameters:
                - width: the width of the board
                - height: the height of the board. width * height - 9 has to be >= numBombs
                - numBombs: the number of bombs
                - boardCreator: a function that takes the width, height, numBombs, and (x, y) of where the first click happened
         */
        init(width: Int, height: Int, numBombs: Int, boardCreator: (Int, Int, Int, Int, Int) -> Board) throws {
            if width * height - 9 < numBombs {
                throw Board.Error.IllegalArgument(reason: "The number of bombs must be greater than width * height - 8");
            }
            
            self.numBombs = numBombs;
            self.board = try Board.createEmptyBoard(width, height: height);
            self.boardCreator = boardCreator;
        }
    }
    
    /// Setting this automatically sets the value of board to `nil`
    var initializer: Initializer? = nil {
        didSet {
            if let _ = initializer {
                self.board = nil;
                self.needsDisplay = true;
            }
        }
    }
    
    
    // Used to mark where the user presses (before releasing the mouse)
    private var mouseDownPoint: NSPoint? = nil;
    // Whether the click was right or left
    private var mouseDownRight: Bool = false;
    
    /// Divides the board and tells the theme to draw the rects
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        //NSLog("Dirty rect:");
        //NSLog("(\(dirtyRect.origin.x), \(dirtyRect.origin.y))");
        //NSLog("Width: \(dirtyRect.width), height: \(dirtyRect.height)");
        //NSLog("CellWidth: \(self.cellWidth), Cellheight: \(self.cellHeight)");
        
        // board from self.board or the initializer (if it exists)
        if let board = (self.board ?? self.initializer?.board) {
            // Draw the board
            let cellWidth = self.cellWidth;
            let cellHeight = self.cellHeight;
            
            var rect = NSRect(x: 0, y: 0, width: cellWidth, height: cellHeight);
            
            // Figure out what tiles need to be drawn (based on dirtyRect)
            let xRange = (start: Int(dirtyRect.origin.x/cellWidth),
                     end: Int((dirtyRect.origin.x + dirtyRect.size.width)/cellWidth));
            let yRange = (start: Int(dirtyRect.origin.y/cellHeight),
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
            
            // draw the borders (only the borders around/in the dirty region)
            // draw the vertical borders:
            let yBorderRange = (start: CGFloat(0), end: bounds.height);
            for x in xRange.start...xRange.end {
                let realX = CGFloat(x) * cellWidth;
                theme.drawBorderLineWithWidth(borderWidth,
                                              start: CGPoint(x: realX, y: yBorderRange.start),
                                              end: CGPoint(x: realX, y: yBorderRange.end));
            }
            
            // draw the horizontal borders:
            let xBorderRange = (start: CGFloat(0), end: bounds.width);
            for y in yRange.start...yRange.end {
                let realY = CGFloat(y) * cellHeight;
                theme.drawBorderLineWithWidth(borderWidth,
                                              start: CGPoint(x: xBorderRange.start, y: realY),
                                              end: CGPoint(x: xBorderRange.end, y: realY));
            }
        }
    }
    
    // MARK: Handling events
    
    override func mouseDown(theEvent: NSEvent) {
        if !enabled || !clickable || (board == nil && initializer == nil){
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
        if !enabled || !clickable || (board == nil && initializer == nil){
            return;
        }
        self.mouseDown(theEvent);
        mouseDownRight = true;
    }
    
    override func mouseUp(theEvent: NSEvent) {
        if !enabled || !clickable || mouseDownPoint == nil {
            return;
        }
        let pt = self.convertPoint(theEvent.locationInWindow, fromView: nil);
        let mouseUpPoint = NSPoint(x: pt.x/cellWidth, y:pt.y/cellHeight);
        if mouseUpPoint.x == mouseDownPoint!.x && mouseUpPoint.y == mouseDownPoint!.y {
            if let board = self.board {
                try! board.pressTile(x: Int(mouseUpPoint.x), y: Int(mouseUpPoint.y));
            } else if let initializer = self.initializer {
                // actually create the board
                self.board = initializer.boardCreator(initializer.board.width, initializer.board.height, initializer.numBombs, Int(mouseUpPoint.x), Int(mouseUpPoint.y));
                try! self.board?.pressTile(x: Int(mouseUpPoint.x), y: Int(mouseUpPoint.y));
                self.initializer = nil;
            }
        }
        setNeedsDisplayInTile(x: Int(mouseDownPoint!.x), y: Int(mouseDownPoint!.y));
        mouseDownPoint = nil;
    }
    
    override func rightMouseUp(theEvent: NSEvent) {
        if !enabled || !clickable || mouseDownPoint == nil || board == nil { // right click on intializing board?
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
        // ignore if there is no board or Initializer
        
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
