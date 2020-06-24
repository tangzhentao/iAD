//
//  ArchiveTask.swift
//  iAD
//
//  Created by void on 2020/6/23.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

enum BuildTpye: String {
    case unknown
    case project = "-project"
    case workspace  = "-workspace"
}

/*
 一般情况下：
 方案名和目标名一样；
 配置文件夹名，Debug环境下名为Debug，Release环境下名为Release，默认使用Release
 
 前提条件：
 只使用Release配置文件；
 sheme和target名字一样
 
 shell命令实例：
 xcodebuild archive -project iADDemo.xcodeproj -scheme iADDemo -configuration Release -archivePath ./0622/iADDemo.xcarchive

 xcodebuild archive -workspace iADDemo.xcworkspace -scheme iADDemo -configuration Release -archivePath ./0622/iADDemo.xcarchive
 */
struct ArchiveTask: Shellable {
    let inPath: String // .xcodeproj/.xcworkspace 完整路径
    let buildTpye: BuildTpye
    let targetName: String // 目标名
    let schemeName: String // 方案名
    let configurationName: String // 配置文件名
    let archivePath: String // 存放归档文件的完整路径
    
    var shellCommand: String {
        launchPath + " " + self.arguments.joined(separator: " ")
    }
    
    // MARK: - Shellable 属性
    var taskName: String {
        "archive"
    }
    let launchPath: String
    var arguments: [String] {
        ["archive",
         buildTpye.rawValue, inPath,
         "-scheme", schemeName,
          "-configuration", configurationName,
          "-archivePath", archivePath
        ]
    }
    
    var terminationStatus: Int32? = nil
    var output: String? = nil;
    
    
    // MARK: - description
    var description: String {
        """
        
        #### archive \(targetName)
        scheme:         \(schemeName)
        configuration:  \(configurationName)
        projectPath:    \(inPath)
        archivePath:    \(archivePath)
        shell:          \(self.shellCommand)

        """
    }
    
    // MARK: - init
    init(inPath: String, targetName: String, schemeName: String, configurationName: String, archivePath: String, launchPath: String) {
        self.launchPath = launchPath
        self.inPath = inPath
        self.targetName = targetName
        self.schemeName = schemeName
        self.configurationName = configurationName
        self.archivePath = archivePath
        
        // 根据工程名确定，构建类型
        let url = URL(fileURLWithPath: inPath)
        let pathExtension = url.pathExtension
        if pathExtension == "xcodeproj" {
            buildTpye = .project
        } else if pathExtension == "xcworkspace" {
             buildTpye = .workspace
        } else {
             buildTpye = .unknown
        }
    }
    
    init(inPath: String, targetName: String, archivePath: String, launchPath: String) {
        
        // 根据输入路径提取工程名 -- project要做的事
        self.init(inPath: inPath, targetName: targetName, schemeName: targetName, configurationName: "Release", archivePath: archivePath, launchPath: launchPath)
    }
    
    func checkArguments() -> Bool {
        print(self.description)
        var pass = true
        if self.buildTpye == .unknown {
            pass = false
            print("参数错误：未知的构建类型")
        }
        return pass
    }
    
    // MARK: - test
    static func test() {
        let launchPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
        let inPath = "/Users/void/projectes/testbed/iADDemo/iADDemo.xcworkspace"
        let targetName = "iADDemo"
        let archivePath = "/Users/void/projectes/testbed/0622/iADDemo.xcarchive"
        var archiveTask = ArchiveTask(inPath: inPath, targetName: targetName, archivePath: archivePath, launchPath: launchPath)
        print(archiveTask.description)

        archiveTask.perform()
        archiveTask.printPerformResult()
    }
}
