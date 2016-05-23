//
//  BoardViewController.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-20.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController, BoardObserver {

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var bombLabel: NSTextField!
    
    var width = 40;
    var height = 20;
    var numBombs = Int(Double(20) * Double(20) * 0.3);
    
    private var timer: NSTimer!;
    private var startTime: NSDate!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func awakeFromNib() {
        happyFace(0);
    }
    
    func updateTimer() {
        let timeDuration = NSDate().timeIntervalSinceDate(startTime);
        timerLabel.stringValue = String(format: "%3.2d:%.2d.%d",
                                        Int(timeDuration) / 60,
                                        Int(timeDuration) % 60,
                                        Int(timeDuration * 10) % 10);
    }
    
    @IBAction func happyFace(sender: AnyObject) {
        // kill the timer
        timer?.invalidate();
        timer = nil;
        
        startTime = nil;
        timerLabel.stringValue = "";
        
        // remove self from board
        self.boardView.board?.removeObserver(self);
        self.boardView.clickable = true;
        self.boardView.enabled = true;
        
        bombLabel.stringValue = String(numBombs);
        
        boardView.initializer = try! BoardView.Initializer(
            width: width,
            height: height,
            numBombs: numBombs,
            boardCreator: {
                print("Creating board");
                let board = try! Board.createRandomBoard($0, height: $1, numBombs: $2, x: $3, y: $4);
                // add an observer so that we can track the number of flagged tiles
                board.addObserver(self);
                
                // and create a timer
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true);
                self.startTime = NSDate();
                
                return board;
        });
        
    }
    
    func tileChanged(x x: Int, y: Int, tile: Tile) {
        // update bomb Label
        print("\(boardView.board!.numBombs) - \(boardView.board!.numFlagged)");
        let value = boardView.board!.numBombs - (boardView.board!.numFlagged + boardView.board!.numFlaggedWrong);
        bombLabel.stringValue = String(value);
    }
    func gameWon(x x: Int, y: Int) {
        timer.invalidate();
        timer = nil;
    }
    func gameLost(x x: Int, y: Int) {
        timer.invalidate();
        timer = nil;
    }
}
