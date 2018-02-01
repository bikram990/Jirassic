//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet fileprivate var tabView: NSTabView!
    @IBOutlet fileprivate var butBackup: NSButton!
    @IBOutlet fileprivate var butEnableLaunchAtStartup: NSButton!
    
    // Tracking tab
    @IBOutlet fileprivate var butAutotrack: NSButton!
    @IBOutlet fileprivate var autotrackingModeSegmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate var butTrackStartOfDay: NSButton!
    @IBOutlet fileprivate var butTrackLunch: NSButton!
    @IBOutlet fileprivate var butTrackScrum: NSButton!
    @IBOutlet fileprivate var butTrackMeetings: NSButton!
    @IBOutlet fileprivate var startOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var endOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minSleepDurationLabel: NSTextField!
    @IBOutlet fileprivate var minSleepDurationSlider: NSSlider!

    // Input tab
    @IBOutlet fileprivate var inputsScrollView: InputsScrollView!
    // Output tab
    @IBOutlet fileprivate var outputsScrollView: OutputsScrollView!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    override func viewDidAppear() {
        super.viewDidAppear()
        createLayer()
        
        presenter!.checkExtensions()
        presenter!.showSettings()
        
        #if !APPSTORE
            butBackup.isEnabled = false
            butBackup.state = NSControl.StateValue.off
            butEnableLaunchAtStartup.isEnabled = false
            butEnableLaunchAtStartup.state = NSControl.StateValue.off
        #endif
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        let settings = Settings(
            
            autotrack: butAutotrack.state == NSControl.StateValue.on,
            autotrackingMode: TrackingMode(rawValue: autotrackingModeSegmentedControl.selectedSegment)!,
            trackLunch: butTrackLunch.state == NSControl.StateValue.on,
            trackScrum: butTrackScrum.state == NSControl.StateValue.on,
            trackMeetings: true,//butTrackMeetings.state == NSControl.StateValue.on,
            trackStartOfDay: butTrackStartOfDay.state == NSControl.StateValue.on,
            enableBackup: butBackup.state == NSControl.StateValue.on,
            startOfDayTime: startOfDayTimePicker.dateValue,
            endOfDayTime: endOfDayTimePicker.dateValue,
            lunchTime: lunchTimePicker.dateValue,
            scrumTime: scrumTimePicker.dateValue,
            minSleepDuration: minSleepDurationSlider.integerValue,
            settingsBrowser: inputsScrollView.settings()
        )
        presenter!.saveAppSettings(settings)
    }
    
    deinit {
        RCLog("deinit")
    }
}

extension SettingsViewController {
	
    @IBAction func handleSaveButton (_ sender: NSButton) {
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleAutoTrackButton (_ sender: NSButton) {
        autotrackingModeSegmentedControl.isEnabled = sender.state == NSControl.StateValue.on
    }
    
    @IBAction func handleBackupButton (_ sender: NSButton) {
        presenter!.enabledBackup(sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func handleLaunchAtStartupButton (_ sender: NSButton) {
        presenter!.enabledLaunchAtStartup(sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func handleMinSleepDuration (_ sender: NSSlider) {
        minSleepDurationLabel.stringValue = "Ignore sleeps shorter than \(sender.integerValue) minutes"
    }
}

extension SettingsViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            jirassicImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
//            jirassicTextField.stringValue = compatible ? "Run 'jirassic' in Terminal for more info" : "Applescript installed but jirassic cmd is outdated/uninstalled"
//        } else {
//            jirassicImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            jirassicTextField.stringValue = "Not installed yet"
//        }
//        butInstallJirassic.isHidden = scriptInstalled && compatible
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            jitImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
//            jitTextField.stringValue = compatible ? "Commits made with Jit will log time to Jirassic. Run 'jit' in Terminal for more info" : "Applescript installed but jit cmd is outdated/uninstalled"
//        } else {
//            jitImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            jitTextField.stringValue = "Not installed yet"
//        }
//        butInstallJit.isHidden = scriptInstalled && compatible
    }
    
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            coderevImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusUnavailable)
//            coderevTextField.stringValue = compatible ? "Jirassic can read the url of your browser and it will log time based on it" : "Applescript installed but outdated"
//        } else {
//            coderevImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            coderevTextField.stringValue = "Not installed yet"
//        }
//        butInstallCoderev.isHidden = scriptInstalled && compatible
    }
    
    func showAppSettings (_ settings: Settings) {
        
        // Tracking
        
        butAutotrack.state = settings.autotrack ? NSControl.StateValue.on : NSControl.StateValue.off
        autotrackingModeSegmentedControl.selectedSegment = settings.autotrackingMode.rawValue
        minSleepDurationSlider.integerValue = settings.minSleepDuration
        handleMinSleepDuration(minSleepDurationSlider)
        butTrackStartOfDay.state = settings.trackStartOfDay ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackLunch.state = settings.trackLunch ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackScrum.state = settings.trackScrum ? NSControl.StateValue.on : NSControl.StateValue.off
        
        startOfDayTimePicker.dateValue = settings.startOfDayTime
        endOfDayTimePicker.dateValue = settings.endOfDayTime
        lunchTimePicker.dateValue = settings.lunchTime
        scrumTimePicker.dateValue = settings.scrumTime

        inputsScrollView.showSettings(settings.settingsBrowser)
        
        // Generic
        
        butBackup.state = settings.enableBackup ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enabledBackup (_ enabled: Bool, title: String) {
        butBackup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
        butBackup.title = title
    }
    
    func selectTab (atIndex index: Int) {
        tabView.selectTabViewItem(at: index)
        if index == 2 {
//            presenter?.loadJiraProjects()
        }
    }
}

extension SettingsViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let item = tabViewItem {
            localPreferences.set( tabView.indexOfTabViewItem(item), forKey: .settingsActiveTab)
        }
    }
}
