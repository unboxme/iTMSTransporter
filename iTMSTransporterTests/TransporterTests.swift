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

import XCTest
@testable import iTMSTransporter

class TransporterTests: XCTestCase {
    
    private enum Constants {
        static let username: String = ""
        static let password: String = ""
        static let sku: String = ""
    }

    override func setUp() {
        Transporter.setup(username: Constants.username, password: Constants.password)
    }

    func testLookup() {
        let lookupWaiting = expectation(description: "Lookup")
        
        let downloadPath = FileManager.default.homeDirectoryForCurrentUser
        
        Transporter.lookup(sku: Constants.sku, downloadPath: downloadPath) { result in
            switch result {
            case .success(let model):
                if let log = model.outputLog {
                    print("Output:\n" + log)
                }
                if let log = model.errorLog {
                    print("Error:\n" + log)
                }
            case .failure(let error):
                print(error)
            }
            lookupWaiting.fulfill()
        }
        
        wait(for: [lookupWaiting], timeout: 60)
    }
}
