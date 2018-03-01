//
//  ParseGitBranchTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 28/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class ParseGitBranchTests: XCTestCase {

    func test() {
        
        var parser = ParseGitBranch(branchName: "AA-1234-branch-name")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "branch name")
        
        parser = ParseGitBranch(branchName: "AA-1234__branch_name")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "branch name")
        
        parser = ParseGitBranch(branchName: "some_branch_name")
        XCTAssertNil(parser.taskNumber())
        XCTAssert(parser.taskTitle() == "some branch name")
    }
    
    func testMergeCommitMessage() {
        // Merge pull request #619 in BSEAPP/bsa-ios from APP-3494-ios-remove-a-confirmation-e-mail to master;
    }
    
    func testBranchesFromLog() {
        // origin/Enable_disable_nyon_framework_file_logs, Enable_disable_nyon_framework_file_logs
        // origin/APP-1695-sync-devices-on-ush
    }
}