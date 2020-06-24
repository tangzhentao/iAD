//
//  Shellable.swift
//  iAD
//
//  Created by void on 2020/6/23.
//  Copyright © 2020 void. All rights reserved.
//

import Foundation

// 可shell的
protocol Shellable {
    // MARK: - 输入
    var launchPath: String {get}
    var arguments: [String] {get}
    var taskName: String {get}
    // MARK: - 输出
    var terminationStatus: Int32? {get set} // 退出状态
    var output: String? {get set} // 命令执行过程中的输出

    // MARK: - 执行
    // 提供默认实现
    mutating func perform(captureOuput: Bool)
    // 提供默认实现
    func shell(captureOuput: Bool) -> (Int32, String?)
    // 不提供默认实现，下方到具体的类型去实现
    func checkArguments() -> Bool
    // 提供默认实现
    func printPerformResult()
}

extension Shellable {
    mutating func perform(captureOuput: Bool = true) {
        
        // 检查参数，
        guard self.checkArguments() else {
            self.terminationStatus = -1
            self.output = "参数错误"
            return
        }
        
        (self.terminationStatus, self.output) = shell(captureOuput: captureOuput)
    }
    
    func shell(captureOuput: Bool = false) -> (Int32, String?)
    {
        let task = Process()
        task.launchPath = self.launchPath
        task.arguments = self.arguments
        var pipe: Pipe? = nil;
        if captureOuput {
            pipe = Pipe()
            task.standardOutput = pipe
        }

        task.launch()

        var output: String? = nil
        if let data = pipe?.fileHandleForReading.readDataToEndOfFile() {
            output = String(data: data, encoding: String.Encoding.utf8)
        }
        task.waitUntilExit()
        
        let status = task.terminationStatus
        pipe?.fileHandleForReading.closeFile()
        
        return (status, output)
    }
    
    func printPerformResult() {
        let status = self.terminationStatus ?? -1
        let result = """
        \(self.taskName) status: \(status)
        error info: \(status == 0 ? "no error" : self.output ?? "no output")
        #### 

        """
        print(result)
    }
}
