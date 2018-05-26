//
//  YAssistiveButton.swift
//  YSAssistiveTouch
//
//  Created by ikicker100 on 2018/5/25.
//  Copyright © 2018年 YSObject. All rights reserved.
//

import UIKit

public enum YAssistiveType {
    case YAssistiveTypeNone
    case YAssistiveTypeHorizontalScroll //水平
    case YAssistiveTypeVerticalScroll  //垂直
}

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

public class YAssistiveButton: UIButton {
    
   public var assistiveType:YAssistiveType?
   public var startAlpha:CGFloat?
   public var stopAlpha:CGFloat?
    
    public init(_ assistiveType:YAssistiveType? = .YAssistiveTypeNone,frame:CGRect,_ startAlpha:CGFloat? = 0.8, _ stopAlpha:CGFloat? = 0.3) {
        self.assistiveType = assistiveType
        self.startAlpha = startAlpha
        self.stopAlpha = stopAlpha
        super.init(frame: frame)
        self.alpha = stopAlpha!
        let pan = UIPanGestureRecognizer(target: self, action: #selector(assistivePanGesture(recognizer:)))
        self.addGestureRecognizer(pan)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YAssistiveButton{
    @objc func assistivePanGesture(recognizer:UIPanGestureRecognizer) -> Void {
        let point = recognizer.translation(in: self)
        var assistiveFrame:CGRect = self.frame
        
        switch (self.assistiveType){
            
            case YAssistiveType.YAssistiveTypeNone?:
                assistiveFrame = self.animateHorizontalScroll(assistiveFrame: assistiveFrame, point: point)
                assistiveFrame = self.animateVerticalScroll(assistiveFrame: assistiveFrame, point: point)
                break
            case YAssistiveType.YAssistiveTypeVerticalScroll?:
                assistiveFrame = self.animateVerticalScroll(assistiveFrame: assistiveFrame, point: point)
                break
            case YAssistiveType.YAssistiveTypeHorizontalScroll?:
                assistiveFrame = self.animateHorizontalScroll(assistiveFrame: assistiveFrame, point: point)
                break
            default: break
        }
        self.frame = assistiveFrame
        recognizer.setTranslation(CGPoint.zero, in: self)
        guard let ButtonView = recognizer.view else {
            return
        }
        if ButtonView.isKind(of: UIButton.self) {
            let btn = ButtonView as! UIButton
            if recognizer.state == .began{
                btn.isEnabled = false
                btn.alpha = self.startAlpha!
            }else if recognizer.state == .changed{
                
            }else{
                let defaultFrame = self.frame
                self.animateEndFrame(endFrame: defaultFrame,recognizer:recognizer)
                btn.isEnabled = true
            }
        }
    }
    
    //水平
    func animateHorizontalScroll(assistiveFrame:CGRect,point:CGPoint) -> CGRect {
        var resultFrame = assistiveFrame
        let min = assistiveFrame.origin.x >= 0
        let max = assistiveFrame.origin.x + assistiveFrame.size.width <= SCREEN_WIDTH
        if (min && max){
            resultFrame.origin.x += point.x
        }
        return resultFrame
    }
    
    //垂直
    func animateVerticalScroll(assistiveFrame:CGRect,point:CGPoint) -> CGRect {
        var resultFrame = assistiveFrame
        let min = assistiveFrame.origin.y >= 0
        let max = assistiveFrame.origin.y + assistiveFrame.size.height <= SCREEN_HEIGHT
        if (min && max){
            resultFrame.origin.y += point.y
        }
        return resultFrame
    }
    
    func animateEndFrame(endFrame:CGRect,recognizer:UIPanGestureRecognizer) -> Void {
        var changeFrame:CGRect = self.frame
        var isboundary:Bool? = false
        
        if endFrame.origin.x <= 0{
            isboundary = true
            changeFrame.origin.x = 0
        }else if (endFrame.origin.x + endFrame.size.width > SCREEN_WIDTH){
            changeFrame.origin.x = SCREEN_WIDTH - endFrame.size.width
            isboundary = true
        }
        
        if endFrame.origin.y <= 0{
            isboundary = true
            changeFrame.origin.y = 0
        }else if (endFrame.origin.y + endFrame.size.height > SCREEN_HEIGHT){
            changeFrame.origin.y = SCREEN_HEIGHT - endFrame.size.height
            isboundary = true
        }
        if isboundary! {
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
                self.frame = changeFrame
            }, completion: { (result) in
                self.stopAnimate()
            })
            
        }else{
            self.stopAnimate()
        }
    }
    
    func stopAnimate() -> Void {
        UIView.animate(withDuration: 3, delay: 1.5, options: [], animations: {
            self.alpha = self.stopAlpha!
        }, completion: nil)
    }
    
}
