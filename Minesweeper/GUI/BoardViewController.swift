//
//  BoardViewController.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-23.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController, BoardObserver {
    
    
    lazy var theme: BoardTheme = SimpleTheme();
    var boardSpec: Board.Spec = Board.Spec(width: 20, height: 20, numBombs: 40) {
        didSet {
            boardView.initializer = try! BoardView.Initializer(
                width: boardSpec.width,
                height: boardSpec.height,
                numBombs: boardSpec.numBombs,
                boardCreator: { try! Board.createRandomBoard($0, height: $1, numBombs: $2, x: $3, y: $4) });
        }
    }
    
    lazy var controlBox = NSView();
    lazy var timerLabel = NSView();
    lazy var bombsLabel = NSView();
    lazy var resetButton = NSButton();
    lazy var boardView: BoardView = BoardView();
    
    var startTime: NSDate? = nil;
    var timeElapsed: NSTimeInterval {
        if let start = startTime {
            return NSDate().timeIntervalSinceDate(start);
        }
        return 0;
    }
    var timer: NSTimer? = nil;

    // Can be used to initialize or refresh the views
    func createView() {
        // Appearance:
        // Control Box | <timer> <reset button> <num bombs> |
        // Board
        
        // Create and initialize the components
        controlBox = NSView();
        
        resetButton = theme.resetButton;
        timerLabel = theme.timerLabel;
        bombsLabel = theme.bombsLabel;
        boardView = BoardView(); // recreate it to get rid of garbage
        // Initialize them (0 values)
        theme.updateTimerLabel(timerLabel, time: 0);
        theme.updateBombsLabel(bombsLabel, value: boardSpec.numBombs);
        
        // Make timerLabel, resetButton, and bombsLabel ignore their bounds
        timerLabel.translatesAutoresizingMaskIntoConstraints = false;
        resetButton.translatesAutoresizingMaskIntoConstraints = false;
        bombsLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        controlBox.translatesAutoresizingMaskIntoConstraints = false;
        boardView.translatesAutoresizingMaskIntoConstraints = false;
        
        // Add constraints to the things in controlBox
        // Add them to the control box
        controlBox.addSubview(timerLabel);
        controlBox.addSubview(resetButton);
        controlBox.addSubview(bombsLabel);
        // center them vertically
        controlBox.addConstraint(NSLayoutConstraint(
            item: timerLabel, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: controlBox, attribute: .CenterY, multiplier: 1, constant: 0));
        controlBox.addConstraint(NSLayoutConstraint(
            item: resetButton, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: controlBox, attribute: .CenterY, multiplier: 1, constant: 0));
        controlBox.addConstraint(NSLayoutConstraint(
            item: bombsLabel, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: controlBox, attribute: .CenterY, multiplier: 1, constant: 0));
        // Position them horizontally
        let timerMinWidth = theme.minTimerLabelBounds != nil ? ("(>=" + String(theme.minTimerLabelBounds!.width) + ")") : "";
        let bombsMinWidth = theme.minBombsLabelBounds != nil ? ("(>=" + String(theme.minBombsLabelBounds!.width) + ")") : "";
        let resetMinWidth = theme.minResetButtonBounds != nil ? ("(>=" + String(theme.minResetButtonBounds!.width) + ")") : "";
        controlBox.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[timer\(timerMinWidth)]-(>=10)-[reset\(resetMinWidth)]-(>=10)-[bombs\(bombsMinWidth)]-|",
            options: .AlignAllCenterY, metrics: nil, views: ["timer": timerLabel, "reset": resetButton, "bombs": bombsLabel]));
        
        // Add their minimum height constraint
        if let minHeight = theme.minTimerLabelBounds?.height {
            controlBox.addConstraint(NSLayoutConstraint(item: timerLabel, attribute: .Height,
                relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 0, constant: minHeight));
        }
        if let minHeight = theme.minResetButtonBounds?.height {
            controlBox.addConstraint(NSLayoutConstraint(item: resetButton, attribute: .Height,
                relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 0, constant: minHeight));
        }
        if let minHeight = theme.minBombsLabelBounds?.height {
            controlBox.addConstraint(NSLayoutConstraint(item: bombsLabel, attribute: .Height,
                relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 0, constant: minHeight));
        }
        
        // Add an additional constraint that resetButton is cenetered (horizontally)
        controlBox.addConstraint(NSLayoutConstraint(
            item: resetButton, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: controlBox, attribute: .CenterX, multiplier: 1, constant: 0));
        
        
        
        // Position control box and board View
        view.addSubview(controlBox);
        view.addSubview(boardView);
        boardView.initializer = try! BoardView.Initializer(
            width: boardSpec.width, height: boardSpec.height, numBombs: boardSpec.numBombs, boardCreator: generateBoard);
        
        // calculate the constraints for the boardView (based on the tile information)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controlBox(==\(theme.controlBoxHeight))][boardView]|",
            options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["controlBox": controlBox, "boardView": boardView]));
        // make both the controlBox and boardView's widths equal to the superview
        view.addConstraint(NSLayoutConstraint(
            item: controlBox, attribute: .Width,
            relatedBy: .Equal,
            toItem: view, attribute: .Width, multiplier: 1, constant: 0));
        view.addConstraint(NSLayoutConstraint(
            item: boardView, attribute: .Width,
            relatedBy: .Equal,
            toItem: view, attribute: .Width, multiplier: 1, constant: 0));
        
        // Add minimum and max bounds constraints to the board view
        if let min = theme.minTileBounds {
            view.addConstraint(NSLayoutConstraint(item: boardView, attribute: .Width,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil, attribute: .Width, multiplier: 0, constant: min.width * CGFloat(boardSpec.width)));
            view.addConstraint(NSLayoutConstraint(item: boardView, attribute: .Height,
                relatedBy: .GreaterThanOrEqual,
                toItem: nil, attribute: .Width, multiplier: 0, constant: min.height * CGFloat(boardSpec.height)));
        }
        if let max = theme.maxTileBounds {
            view.addConstraint(NSLayoutConstraint(item: boardView, attribute: .Width,
                relatedBy: .LessThanOrEqual,
                toItem: nil, attribute: .Width, multiplier: 0, constant: max.width * CGFloat(boardSpec.width)));
            view.addConstraint(NSLayoutConstraint(item: boardView, attribute: .Height,
                relatedBy: .LessThanOrEqual,
                toItem: nil, attribute: .Width, multiplier: 0, constant: max.height * CGFloat(boardSpec.height)));
        }
        // the shape of the tiles
        if let shapeInfo = theme.tileShape {
            view.addConstraint(NSLayoutConstraint(item: boardView, attribute: .Width,
                relatedBy: shapeInfo.relation, toItem: boardView, attribute: .Height, multiplier: shapeInfo.multiplier, constant: shapeInfo.constant));
        }
        
        resetButton.target = self;
        resetButton.action = #selector(resetButtonPressed);
    }
    
    func resetButtonPressed() {
        // reset the board
        gameEnded();
        boardView.initializer = try! BoardView.Initializer(
            width: boardSpec.width, height: boardSpec.height, numBombs: boardSpec.numBombs, boardCreator: generateBoard);
    }
    
    func timerUpdate() {
        theme.updateTimerLabel(timerLabel, time: timeElapsed);
    }
    
    func tileChanged(x x: Int, y: Int, tile: Tile) {
        // update the bombs count
        theme.updateBombsLabel(bombsLabel, value: boardView.board!.numBombs - boardView.board!.numFlagged - boardView.board!.numFlaggedWrong);
    }
    
    func gameEnded() {
        // invalidate the timer
        timer?.invalidate();
        timer = nil;
    }
    func gameLost(x x: Int, y: Int) {
        gameEnded();
    }
    
    func gameWon(x x: Int, y: Int) {
        gameEnded();
    }
    
    func generateBoard (width: Int, height: Int, numBombs: Int, x: Int, y: Int) -> Board {
        // start the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true);
        timer?.tolerance = 0.01;
        startTime = NSDate();
        let board = try! Board.createRandomBoard(width, height: height, numBombs: numBombs, x: x, y: y);
        board.addObserver(self);
        return board;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView();
    }
    
    typealias FormattedTime = (hours: Int, minutes: Int, seconds: Int, milliseconds: Int);
    class func convertTimeDuration(duration: NSTimeInterval) ->  FormattedTime {
        let hours = Int(duration) / 3600;
        let min = (Int(duration) / 60) % 60;
        let sec = Int(duration) % 60;
        let milli = Int(duration * 1000) % 1000;
        
        return FormattedTime(hours: hours, minutes: min, seconds: sec, milliseconds: milli);
    }
}
