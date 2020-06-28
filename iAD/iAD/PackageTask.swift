//
//  PackageTask.swift
//  iAD
//
//  Created by void on 2020/6/23.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

/*
 打包任务是要把源代码打包成ipa文件，包括两个步骤：
    1. archive: 把源代码归档.xcarchive文件
    2. export: 把归档的文件导出为ipa文件
 */

struct PackageTask {
    let inPath: String // .xcodeproj/.xcworkspace 完整路径
    let targetName: String // 目标名
    let outDirectory: String // 保存输出ipa文件的目录的完整路径
    let launchPath: String // .xcodeproj/.xcworkspace 完整路径
    
    // MARK: - description
    var description: String {
        """
        ## package \(targetName)
        inPath:         \(inPath)
        outDirectory:   \(outDirectory)
        launchPath:     \(launchPath)

        """
    }
    
    var terminationStatus: Int32? = nil
    var output: String? = nil;

    var archiveTask: ArchiveTask
    var exportTask: ExportTask
    
    init(inPath: String, targetName: String, outDirectory: String, launchPath: String) {
        self.inPath = inPath
        self.targetName = targetName
        self.outDirectory = outDirectory
        self.launchPath = launchPath
        
        var url = URL(fileURLWithPath: outDirectory)
        url.appendPathComponent(targetName)
        url.appendPathExtension("xcarchive")
        self.archiveTask = ArchiveTask(inPath: inPath, targetName: targetName, archivePath: url.path, launchPath: launchPath)
        self.exportTask = ExportTask(archivePath: url.path, targetName: targetName, exportDirectory: outDirectory, launchPath: launchPath)
    }
    
    mutating func perform() {
        
        // 检查参数
        guard self.checkArguments() else {
            print("* 参数错误")
            return
        }
        
        // archive
        self.archiveTask.perform(captureOuput: false)
        self.archiveTask.printPerformResult()
        self.terminationStatus = self.archiveTask.terminationStatus
        self.output = self.archiveTask.output
        guard self.archiveTask.terminationStatus == 0 else {
            return
        }
        // export
        self.exportTask.perform(captureOuput: false)
        self.exportTask.printPerformResult()
        self.terminationStatus = self.exportTask.terminationStatus
        self.output = self.exportTask.output
    }
    
    func checkArguments() -> Bool {
        var pass = true
        if self.createOutDirectoryIfNeeded() == false {
            pass = false
        }
        
        return pass
    }
    
    func createOutDirectoryIfNeeded() -> Bool {
        
        var result = true
        
        // 先判断目录是否存在，不存在就创建
        var isDirectory: ObjCBool = false
        let exist = FileManager.default.fileExists(atPath: self.outDirectory, isDirectory: &isDirectory)
        // 不存在就创建
        if exist == false {
            do {
                try FileManager.default.createDirectory(atPath: self.outDirectory, withIntermediateDirectories: true, attributes: nil)
                print("* 创建outDirectory成功:", self.outDirectory)

            } catch  {
                print("* 创建outDirectory时遇到错误:", error)
                result = false
            }
        } else if isDirectory.boolValue == false {
            print("* outDirectory存在，但不是目录:", self.outDirectory)
            result = false
        }

        return result
    }
    
    func printPerformResult() {
        let status = self.terminationStatus ?? -1
        let result = """
        package status: \(status)
        error info: \(status == 0 ? "no error" : self.output ?? "no output")
        ********** ***** **********

        """
        print(result)
    }
    
    // MARK: - test
    static func test() {
        let launchPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
        let targetName = "iADDemo"
        let inPath = "/Users/void/projectes/testbed/iADDemo/iADDemo.xcworkspace"
        let exportDirectory = "/Users/void/projectes/testbed/0624/"

        var packageTask = PackageTask(inPath: inPath, targetName: targetName, outDirectory: exportDirectory, launchPath: launchPath)
        print(packageTask.description)

        packageTask.perform()
        packageTask.printPerformResult()
    }
}
