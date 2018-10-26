//
//  ReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsHeaderView: NSTableHeaderView {
    
    private var butRound: NSButton
    private var butPercents: NSButton
    private var totalTimeTextField: NSTextField
    private let localPreferences = RCPreferences<LocalPreferences>()
    var didChangeSettings: (() -> Void)?
    // In hours
    var workedTime: String {
        get {
            return ""
        }
        set {
            totalTimeTextField.stringValue = newValue
        }
    }
    var workdayTime: Double {
        get {
            return 0.0
        }
        set {
            butRound.attributedTitle = NSAttributedString(string: "Round to \(newValue) hours", attributes: attributes)
        }
    }
    private let attributes = [NSAttributedStringKey.foregroundColor: NSColor.white]
    
    init (height: CGFloat) {
        
        butPercents = NSButton()
        butPercents.frame = NSRect(x: 15, y: 20, width: 200, height: 20)
        butPercents.attributedTitle = NSAttributedString(string: "Show time in percents", attributes: attributes)
        butPercents.setButtonType(.switch)
        butPercents.state = localPreferences.bool(.usePercents) ? NSControl.StateValue.on : NSControl.StateValue.off
        
        butRound = NSButton()
        butRound.frame = NSRect(x: 200, y: 20, width: 200, height: 20)
        butRound.setButtonType(.switch)
        butRound.state = localPreferences.bool(.enableRoundingDay) ? NSControl.StateValue.on : NSControl.StateValue.off
        butRound.toolTip = "This can be set in 'Settings/Tracking/Working between'"
        
        totalTimeTextField = NSTextField()
        totalTimeTextField.alignment = NSTextAlignment.right
        totalTimeTextField.drawsBackground = false
        totalTimeTextField.isBordered = false
        totalTimeTextField.isEnabled = false
        totalTimeTextField.focusRingType = .none
        totalTimeTextField.textColor = NSColor.white
        totalTimeTextField.backgroundColor = NSColor.clear
        
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: height))
        
        self.workedTime = ""
        self.workdayTime = 0.0
        
        butRound.target = self
        butRound.action = #selector(self.handleRoundButton)
        butPercents.target = self
        butPercents.action = #selector(self.handlePercentsButton)
        
        self.addSubview(butPercents)
        self.addSubview(butRound)
        self.addSubview(totalTimeTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.darkGray.set()
        dirtyRect.fill()
        totalTimeTextField.frame = NSRect(x: dirtyRect.size.width - 80, y: 22, width: 64, height: 20)
    }
}

extension ReportsHeaderView {
    
    @objc func handleRoundButton (_ sender: NSButton) {
        localPreferences.set(sender.state == NSControl.StateValue.on, forKey: .enableRoundingDay)
        didChangeSettings?()
    }
    
    @objc func handlePercentsButton (_ sender: NSButton) {
        localPreferences.set(sender.state == NSControl.StateValue.on, forKey: .usePercents)
        didChangeSettings?()
    }
}
