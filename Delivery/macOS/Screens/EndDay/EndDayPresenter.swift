//
//  EndDayPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol EndDayPresenterInput: class {
    func setup (date: Date, tasks: [Task])
    func save (worklog: String, toJiraTempo: Bool, toHookup: Bool, roundTime: Bool)
}

protocol EndDayPresenterOutput: class {
    func showJira (enabled: Bool, available: Bool)
    func showHookup (enabled: Bool, available: Bool)
    func showRounding (enabled: Bool, title: String)
    func showWorklog (_ worklog: String)
    func showProgressIndicator (_ show: Bool)
    func showJiraError (_ error: String)
    func showHookupError (_ error: String)
}

class EndDayPresenter {
    
    weak var userInterface: EndDayPresenterOutput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    fileprivate var moduleJira = ModuleJiraTempo()
    fileprivate var moduleHookup = ModuleHookup()
    var duration = 0.0
    var date: Date?
    fileprivate var tasks: [Task] = []
}

extension EndDayPresenter: EndDayPresenterInput {

    func setup (date: Date, tasks: [Task]) {
        self.date = date
        self.tasks = tasks
        show(tasks: tasks)
    }
    
    private func show (tasks: [Task]) {
        
        let settings = SettingsInteractor().getAppSettings()
        let isRoundingEnabled = localPreferences.bool(.enableRoundingDay)
        let targetHoursInDay = isRoundingEnabled
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil
        
        let reportInteractor = CreateReport()
        let reports = reportInteractor.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        
        let lines = reports.map({ $0.taskNumber + " - " + $0.title + "\n" + $0.notes })
        let message = lines.joined(separator: "\n\n")
        
        let workdayLength = Date.secondsToPercentTime( TimeInteractor(settings: settings).workingDayLength() )
        let workedLength = Date.secondsToPercentTime( StatisticsInteractor().workedTime(fromReports: reports) )
        duration = isRoundingEnabled ? workdayLength : workedLength
        
        userInterface!.showWorklog(message)
        setupJiraButton()
        setupHookupButton()
        setupRoundingButton(workdayLength: workdayLength, workedLength: workedLength)
    }
    
    private func setupJiraButton() {
        let isJiraAvailable = moduleJira.isReachable
        let isJiraEnabled = isJiraAvailable && localPreferences.bool(.enableJira)
        userInterface!.showJira(enabled: isJiraEnabled, available: isJiraAvailable)
    }
    
    private func setupHookupButton() {
        let isHookupAvailable = localPreferences.bool(.enableHookup)
        let isHookupEnabled = isHookupAvailable && localPreferences.bool(.enableJira)
        userInterface!.showHookup(enabled: isHookupEnabled,
                                  available: isHookupAvailable && self.date!.isToday())
    }
    
    private func setupRoundingButton (workdayLength: TimeInterval, workedLength: TimeInterval) {
        let isRoundingEnabled = localPreferences.bool(.enableRoundingDay)
        userInterface!.showRounding(enabled: isRoundingEnabled,
                                    title: "Round worklogs time to \(String(describing: workdayLength)) hours. Actual worked time is \(String(describing: workedLength))")
    }
    
    func save (worklog: String, toJiraTempo: Bool, toHookup: Bool, roundTime: Bool) {
        
        userInterface!.showJiraError("")
        userInterface!.showHookupError("")
        
        // Find if the day ended already
        let currentEndDayTask: Task? = self.tasks.last
        let endDayDate = currentEndDayTask?.endDate ?? Date()
        let dayAlreadyEnded = currentEndDayTask?.taskType == .endDay
        let endDayTask: Task = dayAlreadyEnded ? currentEndDayTask! : Task(endDate: endDayDate, type: .endDay)
        
        if !dayAlreadyEnded {
            let interactor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
            interactor.saveTask(endDayTask, allowSyncing: true) { (savedTask) in

            }
        }
        
        if moduleJira.isReachable && toJiraTempo {
            userInterface!.showProgressIndicator(true)
            moduleJira.upload(worklog: worklog, duration: duration, date: date!) { [weak self] success in
                DispatchQueue.main.async {
                    guard let userInterface = self?.userInterface else {
                        return
                    }
                    userInterface.showProgressIndicator(false)
                    if !success {
                        userInterface.showJiraError("Couldn't save the worklogs to Jira")
                    }
                }
            }
        }
        
        // Call hookup only for the current day
        if toHookup && self.date!.isSameDayAs(endDayDate) {
            moduleHookup.insert(task: endDayTask) { [weak self] success in
                guard let userInterface = self?.userInterface else {
                    return
                }
                if !success {
                    userInterface.showHookupError("Couldn't call the hookup")
                }
            }
        }
    }
}
