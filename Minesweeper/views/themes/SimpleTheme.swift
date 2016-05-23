//
//  SimpleTheme.swift
//  Minesweeper
//
//  Created by John Rizkalla on 2016-05-09.
//  Copyright © 2016 John Rizkalla. All rights reserved.
//

import Cocoa

/**
    The default theme. Represents a very simple theme with:
    * Gray squares for hidden tiles
    * Gray squares with a green <span style="color:green">"F"</span> for flagged tiles
    * White tiles for unhidden tiles
    * Numbers with colors:
        - <span style="color:blue">1: blue</span>
        - <span style="color:green">2: green</span>
        - <span style="color:red">3: red</span>
        - <span style="color:purple">4: purple</span>
        - <span style="color:magenta">5: magenta</span>
        - <span style="color:cyan">6: cyan</span>
        - 7: black
        - <span style="color:gray">8: gray</span>
    * And finally, a red <span style="color:red">"*"</span> for bombs
 
    - Note:
    `SimpleTheme`, because it's the default theme, does not use owner. Unlike
    other themes, owner will not be set to the real value (will always be `nil`)
 */
class SimpleTheme: BoardTheme {
    var requiresSquare: Bool {
        return true;
    }
    
    weak var owner: BoardView! = nil;
    
    // A cache of the font used to draw because calculating
    // the font size is a relatively expensive operation
    var fontCache: NSFont? = nil;
    // the width fontCache was calculated for
    var widthCache = CGFloat(-1);
    // the height fontCache was calculated for
    var heightCache = CGFloat(-1);
    
    
    func drawTileInRect(rect: NSRect, tile: Board.UserTile, state: BoardView.PressState, enabled: Bool) {
        // draw the background rectangle
        let path = NSBezierPath(rect: rect);
        if tile.isHidden {
            NSColor.grayColor().setFill();
        } else {
            NSColor.whiteColor().setFill();
        }
        path.fill();
        
        // Draw the text if we need to
        var textToDraw: NSString;
        var textColor = NSColor.blackColor();
        switch tile.value {
        case .Flagged:
            textColor = NSColor.greenColor();
            textToDraw = "F";
        case .Num(let num):
            textToDraw = String(num);
            if num == 1 {
                textColor = NSColor.blueColor();
            } else if num == 2 {
                textColor = NSColor.greenColor();
            } else if num == 3 {
                textColor = NSColor.redColor();
            } else if num == 4 {
                textColor = NSColor.purpleColor();
            } else if num == 5 {
                textColor = NSColor.magentaColor();
            } else if num == 6 {
                textColor = NSColor.cyanColor();
            } else if num == 7 {
                textColor = NSColor.blackColor();
            } else if num == 8 {
                textColor = NSColor.grayColor();
            }
        case .Bomb:
            textColor = NSColor.redColor();
            textToDraw = "*";
        default:
            textToDraw = "";
            break;
        }
        if textToDraw.length > 0 {
            // draw it
            // What's the font?
            var font: NSFont;
            if fontCache != nil && widthCache == rect.width && heightCache == rect.height {
                font = fontCache!;
            } else {
                font = BoardView.fontForString(textToDraw as String, width: rect.width, height: rect.height);
                fontCache = font;
                widthCache = rect.width;
                heightCache = rect.height;
            }
            // center it...
            let fontRect = textToDraw.boundingRectWithSize(rect.size, options: .init(rawValue: 0), attributes:
                [NSFontAttributeName: font]);
            
            var newRect = NSRect(origin: rect.origin, size: rect.size);
            newRect.origin.x = (rect.width - fontRect.width)/2 + rect.origin.x;
            newRect.origin.y = (rect.height - fontRect.height)/2 + rect.origin.y;
            
            textToDraw.drawInRect(newRect, withAttributes:
                [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]);
        }
        
        if !enabled {
            // Draw a shaded rectangle...
            let color = NSColor(calibratedWhite: 0.7, alpha: 0.5);
            color.setFill();
            path.fill();
        }
    }
    
    func drawBorderLineWithWidth(width: CGFloat, start: CGPoint, end: CGPoint){
        NSColor.blackColor().setStroke();
        let path = NSBezierPath();
        path.lineWidth = width;
        path.moveToPoint(start);
        path.lineToPoint(end);
        path.stroke();
    }
    
    func drawBackgroundRect(rect: NSRect) {
        assert(false);
    }
}