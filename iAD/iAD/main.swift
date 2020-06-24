//
//  main.swift
//  iAD
//
//  Created by void on 2020/6/22.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

let args = ProcessInfo.processInfo.arguments
if args.count < 3 {
    fatalError("没提供足够的参数")
}

let inPath = args[1]
let targetName = args[2]
print("inPath:", inPath)
print("targetName:", targetName)

var rootPath: NSString = "~/ipa"
let rootDirectory = rootPath.expandingTildeInPath

var packageManager = PackageManager(inPath: inPath, targetNames: [targetName], rootDirectory: rootDirectory)
packageManager.createTasks()
packageManager.prepareHandleTasks()
packageManager.handleTasks()


// 测试归档
//ArchiveTask.test()

// 测试导出ipa
//ExportTask.test()

// 测试打包
//PackageTask.test()


print(" ------------------- end -------------------")
