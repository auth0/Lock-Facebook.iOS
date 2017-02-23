// LockFacebookSpec.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

import Quick
import Nimble
import Auth0
@testable import LockFacebook

class LockFacebookSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com")

        describe("init") {
            var lockFacebook: LockFacebook?

            beforeEach {
                lockFacebook = nil
            }

            it("should init with authentication") {
                lockFacebook = LockFacebook(authentication: authentication)
                expect(lockFacebook).toNot(beNil())
            }
        }

        describe("login") {
            var lockFacebook: LockFacebook!
            var transaction: NativeAuthTransaction?

            beforeEach {
                lockFacebook = LockFacebook(authentication: authentication)
                transaction = nil
            }

            it("should return a transaction") {
                transaction = lockFacebook.login(withConnection: "", scope: "", parameters: [:])
                expect(transaction).toNot(beNil())
            }

            it("should return a transaction with connection facebook") {
                transaction = lockFacebook.login(withConnection: "facebook", scope: "", parameters: [:])
                expect(transaction!.connection) == "facebook"
            }

            it("should return a transaction with scope openid profile") {
                transaction = lockFacebook.login(withConnection: "facebook", scope: "openid profile", parameters: [:])
                expect(transaction!.scope) == "openid profile"
            }

            it("should return a transaction with custom parameters") {
                transaction = lockFacebook.login(withConnection: "facebook", scope: "openid profile", parameters: ["param1": "value1"])
                let value = transaction!.parameters["param1"] as! String
                expect(value) == "value1"
            }

            it("should use specified authentication object") {
                transaction = lockFacebook.login(withConnection: "facebook", scope: "openid profile", parameters: ["param1": "value1"])
                expect(transaction!.authentication.clientId) == authentication.clientId
            }
        }

    }
}
