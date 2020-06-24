//
//  ExportTask.swift
//  iAD
//
//  Created by void on 2020/6/23.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

/*
 shell命令示例
 xcodebuild -exportArchive -archivePath ./0622/iADDemo.xcarchive -exportPath ./0622/iADDemo -exportOptionsPlist ./0622/AdHocExportOptions.plist
 
 - method
 Available options: app-store, validation, ad-hoc, package, enterprise, development, developer-id, and mac-application.
 
 
 ** 说明 **
 关于archive和export，有什么参数不知道什么意思，都可以通过
 xcodebuild -h
 查看
 */

struct ExportTask: Shellable {
    let archivePath: String
    let targetName: String // 目标名
    let exportDirectory: String
    var compileBitcode = false // 默认编译时不支持bitcode
    let method: String = "ad-hoc" // 默认为ad-hoc
    var exportOptionsPlist: String {
        var url = URL(fileURLWithPath: exportDirectory)
        url.appendPathComponent("exportOptions")
        url.appendPathExtension("plist")
        return url.path
    }
    
    
    var shellCommand: String {
          launchPath + " " + self.arguments.joined(separator: " ")
      }
    
    // MARK: - Shellable 属性
    var taskName: String {
        "export"
    }
    let launchPath: String
    var arguments: [String] {
        ["-exportArchive",
         "-archivePath", archivePath,
         "-exportPath", exportDirectory,
         "-exportOptionsPlist", exportOptionsPlist,
        ]
    }
    var terminationStatus: Int32? = nil
    var output: String? = nil;
    
    // MARK: - description
    var description: String {
        """
        #### export \(targetName)
        archivePath:        \(archivePath)
        exportDirectory:    \(exportDirectory)
        exportOptionsPlist: \(exportOptionsPlist)
        exportOptions:      "compileBitcode - \(compileBitcode), method - \(method)"
        shell:              \(self.shellCommand)

        """
    }
    
    //MARK: - 执行前的准备工作
    
    func createExportOptionsPlist() -> Bool{
        
        // 先判断目录是否存在，不存在就创建
        var isDirectory: ObjCBool = false
        let exist = FileManager.default.fileExists(atPath: self.exportDirectory, isDirectory: &isDirectory)
        // 不存在就创建
        if exist == false {
            do {
                try FileManager.default.createDirectory(atPath: self.exportDirectory, withIntermediateDirectories: true, attributes: nil)
                print("* 创建exportDirectory成功:", self.exportDirectory)

            } catch  {
                print("* 创建exportDirectory时遇到错误:", error)
                return false
            }
        } else if isDirectory.boolValue == false {
            print("* exportDirectory存在，但不是目录:", self.exportDirectory)
            return false
        }
        
        let exportOptions: [String : Any] = [
            "compileBitcode" : self.compileBitcode,
            "method" : self.method,
        ]
        
        let exportOptionInfo = exportOptions as NSDictionary
        let result = exportOptionInfo.write(toFile: self.exportOptionsPlist, atomically: true)
        print("* 创建exportOptionsPlist\(result ? "成功" : "失败"):", self.exportOptionsPlist)

        return result
    }
    
    func checkArguments() -> Bool {
        print(self.description)
        var pass = true
        if FileManager.default.fileExists(atPath: self.archivePath) == false {
            pass = false
            print("参数错误: 归档文件不存在:", self.archivePath)
        } else if self.createExportOptionsPlist() == false {
            pass = false
        }
        
        return pass
    }
    
    // MARK: - test
    static func test() {
        let launchPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
        let targetName = "iADDemo"
        let archivePath = "/Users/void/projectes/testbed/0622/iADDemo.xcarchive"
        let exportDirectory = "/Users/void/projectes/testbed/0624/"

        var exportTask = ExportTask(archivePath: archivePath, targetName: targetName, exportDirectory: exportDirectory, launchPath: launchPath)
        print(exportTask.description)

        exportTask.perform()
        exportTask.printPerformResult()
    }
}
