# Lock-Facebook

[![Build Status](https://travis-ci.org/auth0/Lock-Facebook.iOS.svg?branch=master)](https://travis-ci.org/auth0/Lock-Facebook.iOS)
[![Version](https://img.shields.io/cocoapods/v/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)
[![License](https://img.shields.io/cocoapods/l/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)
[![Platform](https://img.shields.io/cocoapods/p/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

Lock-Facebook helps you integrate native Login with [Facebook iOS SDK](https://github.com/facebook/facebook-ios-sdk) and [Lock](https://auth0.com/lock)

## Requirements

- iOS 9 or later
- Xcode 8
- Swift 3.0

## Install

### CocoaPods

 Add the following line to your Podfile:

 ```ruby
 pod "Lock-Facebook", "~> 3.0.0.beta"
 ```

### Carthage

In your `Cartfile` add

```
github "auth0/Lock-Facebook.iOS" "3.0.0.beta"
```

## Usage

First import **LockFacebook**

```swift
import LockFacebook
```

## Before you start using Lock-Facebook

In order to authenticate against Facebook, you'll need to register your application in [Facebook Developer portal](https://developers.facebook.com). We recommend following their [quickstart](https://developers.facebook.com/quickstarts/?platform=ios) for iOS.

If you already have your FacebookAppID, then in your project's `Info.plist` file add the following entries:

* _FacebookAppId_: `YOUR_FACEBOOK_APP_ID`
* _FacebookDisplayName_: `YOUR_FACEBOOK_DISPLAY_NAME`

Then register a custom URL Type with the format `fb<FacebookAppId>`.

Here's an example of how the entries should look like in your `Info.plist` file:

[![FB plist](https://cloudup.com/cYOWHbPp8K4+)](http://auth0.com)

## Usage

Just create a new instance of `LockFacebook` for the default permission `public_profile`

```swift
let lockFacebook = LockFacebook()
```

You can register this handler to a connection name when setting up Lock.


```swift
.handlerAuthentication(forConnectionName: "facebook", handler: lockFacebook)
```

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amont others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free account in Auth0

1. Go to [Auth0](https://auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.

## Author

[Auth0](auth0.com)

## License

Lock-Facebook is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
