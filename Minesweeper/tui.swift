//
//  tui.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-07.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//
import Foundation


class TUI: BoardObserver {
    let board: Board;
    let gameEnded = false;
    var reveal = false;
    
    init() {
        print("Board width: ", terminator: "");
        let width = Int(readLine()!)!;
        print("Board height: ", terminator: "");
        let height = Int(readLine()!)!;
        print("Percent of bombs (0-100): ", terminator: "");
        let perc = Int(readLine()!)!;
        let numBombs = Int(Double(width * height) * (Double(perc) / 100.0));
        
        print("Constructing board with dimensions (\(width), \(height)) and \(numBombs) bombs...");
        
        board = try! Board.createRandomBoard(width, height: height, numBombs: numBombs, x: 0, y: 0);
        board.addObserver(self);
        
        drawBoard();
        print("$> ", terminator: "");
        while true {
            let line = readLine()!;
            let cmd = line.characters.split(" ").map(String.init);
            switch (cmd[0]) {
            case "p":
                let x = Int(cmd[1])!;
                let y = Int(cmd[2])!;
                print("Pressing (\(x), \(y))");
                try! board.pressTile(x: x, y: y);
            case "f":
                let x = Int(cmd[1])!;
                let y = Int(cmd[2])!;
                try! board.flagTile(x: x, y: y);
            case "redraw":
                drawBoard();
            case "reveal":
                reveal = true;
                drawBoard();
            default:
                print("Unknown command");
            }
            if !gameEnded {
                print("$> ", terminator: "");
            } else {
                break;
            }
        }
    }
    
    func drawBoard() {
        print();
        
        print(String(format: "Num Bombs: %3d", board.numBombs - board.numFlagged));
        print("   ", terminator: "");
        for x in 0..<board.width {
            print(String(format: " %02d", x), terminator: "");
        }
        print();
        
        for y in 0..<board.height {
            print(String(format: " %02d", y), terminator: "");
            for x in 0..<board.width {
                var printStr = "   ";
                switch (reveal ? board[x,y].realValue : board[x, y].value) {
                case .Blank:
                    printStr = "   ";
                case .Flagged:
                    printStr = " F ";
                case .Hidden:
                    printStr = " - ";
                case .Bomb:
                    printStr = " * ";
                case .Num(let n):
                    printStr = String(format: "%2d ", n);
                }
                
                print(printStr, terminator: "");
            }
            print();
        }
        
        fflush(__stdoutp);
    }
    
    // MARK: Board stuff
    func tileChanged(x x: Int, y: Int, tile: Tile) {
        drawBoard();
        usleep(50000);
    }
    func gameLost(x x: Int, y: Int) {
        drawBoard();
        print("Game lost!");
    }
    func gameWon(x x: Int, y: Int) {
        drawBoard();
        print("Game won!");
    }
}