//
// Copyright (c) 2019 Puzyrev Pavel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import AppKit

public enum Transporter {
    
    // MARK: - Public Types
    
    public struct Success {
        let file: PathConvertible
        let outputLog: String?
        let errorLog: String?
    }
    
    public enum Failure: Swift.Error {
        case emptyCredentials
        case appLoaderNotInstalled
        case connectionProblem
        case unknown
    }
    
    public typealias Completion = ((Result<Success, Failure>) -> Void)
    
    // MARK: - Private Types
    
    fileprivate enum Mode: String {
        case lookup = "lookupMetadata"
        case verify = "verify"
        case upload = "upload"
    }
    
    fileprivate struct Parameters {
        let sku: String?
        let downloadPath: PathConvertible?
        let filePath: PathConvertible?
        init(sku: String? = nil, downloadPath: PathConvertible? = nil, filePath: PathConvertible? = nil) {
            self.sku = sku
            self.downloadPath = downloadPath
            self.filePath = filePath
        }
    }
    
    // MARK: - Public Methods

    public static func setup(username: String, password: String) {
        Credentials.username = username
        Credentials.password = password
    }
    
    public static func lookup(sku: String, downloadPath: PathConvertible, completion: @escaping Completion) {
        let parameters = Parameters(sku: sku, downloadPath: downloadPath)
        run(mode: .lookup, parameters: parameters, completion: completion)
    }
    
    public static func verify(filePath: PathConvertible, completion: @escaping Completion) {
        run(mode: .verify, parameters: Parameters(filePath: filePath), completion: completion)
    }
    
    public static func upload(filePath: PathConvertible, completion: @escaping Completion) {
        run(mode: .upload, parameters: Parameters(filePath: filePath), completion: completion)
    }
}

private extension Transporter {
    
    static func run(mode: Mode, parameters: Parameters, completion: @escaping Completion) {
        guard let username = Credentials.username, let password = Credentials.password else {
            completion(.failure(.emptyCredentials))
            return
        }
        guard let appPath = NSWorkspace.shared.fullPath(forApplication: "Application Loader") else {
            completion(.failure(.appLoaderNotInstalled))
            return
        }
        guard Reachability.isConnected else {
            completion(.failure(.connectionProblem))
            return
        }
    
        let launchPath = appPath + "/Contents/itms/bin/iTMSTransporter"
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        var arguments = [
            "-m", mode.rawValue,
            "-u", username,
            "-p", password
        ]
        if let vendorId = parameters.sku {
            arguments.append(contentsOf: ["-vendor_id", vendorId])
        }
        if let destination = parameters.downloadPath?.asPath() {
            arguments.append(contentsOf: ["-destination", destination])
        }
        if let filePath = parameters.filePath?.asPath() {
            try? FileManager.default.removeItem(atPath: filePath)
            arguments.append(contentsOf: ["-f", filePath])
        }
        
        let file: String = {
            if let filePath = parameters.filePath?.asPath() {
                return filePath
            }
            if let vendorId = parameters.sku, let destination = parameters.downloadPath?.asPath() {
                return destination + "/\(vendorId).itmsp"
            }
            fatalError("Unexpected case occurred")
        }()
        
        let terminationHandler: ((Process) -> Void) = { process in
            if process.terminationStatus == 0 {
                let model = Success(file: file, outputLog: process.pipedOutputLog, errorLog: process.pipedErrorLog)
                completion(.success(model))
            } else {
                completion(.failure(.unknown))
            }
        }
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.terminationHandler = terminationHandler
        process.launchPath = launchPath
        process.arguments = arguments
        process.launch()
    }
}
