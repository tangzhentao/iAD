//
//  PackageManager.swift
//  iAD
//
//  Created by void on 2020/6/24.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

struct PackageManager {
    let inPath: String
    let targetNames: [String]
    let rootDirectory: String
    let outDirectory: String
    
    let launchPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
    
    var tasks = [PackageTask]()
    
    init(inPath: String, targetNames: [String], rootDirectory: String) {
        self.inPath = inPath
        self.targetNames = targetNames
        self.rootDirectory = rootDirectory
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let directory = df.string(from: date)
        
        var url = URL(fileURLWithPath: rootDirectory)
        url.appendPathComponent(directory)
        self.outDirectory = url.path
    }
    
    @discardableResult func createOutDirectoryIfNeeded() -> Bool {
        
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
    
    mutating func createTasks() {
        for targetName in self.targetNames {
            let packageOutDirectory = (self.outDirectory as NSString).appendingPathComponent(targetName) as String
            let packageTask = PackageTask(inPath: self.inPath, targetName: targetName, outDirectory: packageOutDirectory, launchPath: self.launchPath)
            self.tasks.append(packageTask)
        }
        
        print("* 创建了\(self.tasks.count)任务")
    }
    
    func prepareHandleTasks() {
        self.createOutDirectoryIfNeeded()
    }
    
    func handleTasks() {
        for (index, var packageTask) in self.tasks.enumerated() {
            print("# 开始处理第\(index)个任务:", packageTask.targetName)
            packageTask.perform()
            packageTask.printPerformResult()
        }
    }
}
