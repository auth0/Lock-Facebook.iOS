# Lock-Facebook

[![Build Status](https://travis-ci.org/auth0/Lock-Facebook.iOS.svg?branch=master)](https://travis-ci.org/auth0/Lock-Facebook.iOS)
[![Version](https://img.shields.io/cocoapods/v/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)
[![License](https://img.shields.io/cocoapods/l/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)
[![Platform](https://img.shields.io/cocoapods/p/Lock-Facebook.svg?style=flat)](http://cocoadocs.org/docsets/Lock-Facebook)

[Auth0](https://auth0.com) is an authentication broker that supports social identity providers as well as enterprise identity providers such as Active Directory, LDAP, Google Apps and Salesforce.

Lock-Facebook helps you integrate native Login with [Facebook iOS SDK](https://github.com/facebook/facebook-ios-sdk) and [Lock](https://auth0.com/lock)

## Requierements

iOS 7+

## Install

The Lock-Facebook is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "Lock-Facebook", "~> 2.1"
```

### Build issues with CocoaPods

If you add `uses_frameworks!` flag to your **Podfile**, you'll not be able to build the project with an error similar to the following:

```
Include of non-modular header inside framework module 'FBSDKLoginKit.FBSDKLoginConstants'
```

This is due to how Facebook SDK handles headers. A workaround to this issue is to add the following to your **Podfile**:

```ruby
post_install do |installer|
    installer.pods_project.build_configurations.each { |bc|
        bc.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    }
end
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

Just create a new instance of `A0FacebookAuthenticator` for the default permission `public_profile`

```objc
A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticationWithDefaultPermissions];
```

```swift
let facebook = A0FacebookAuthenticator.newAuthenticatorWithDefaultPermissions()
```

and register it with your instance of `A0Lock`

```objc
A0Lock *lock = //Get your A0Lock instance
[lock registerAuthenticators:@[facebook]];
```

```swift
let lock:A0Lock = //Get your A0Lock instance
lock.registerAuthenticators([facebook])
```
> A good place to create and register `A0FacebookAuthenticator` is the `AppDelegate`class.

### Specify additional **Read** permissions

```objc
A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithPermissions:@[@"public_profile", @"email"]];
```
```swift
let facebook = A0FacebookAuthenticator.newAuthenticatorWithPermissions(["public_profile", "email"])
```

### Custom Facebook connection

```objc
A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithDefaultPermissionsForConnectionName:@"custom-connection-name"];
```
```swift
let facebook = A0FacebookAuthenticator.newAuthenticatorWithDefaultPermissionsForConnectionName("custom-connection-name")
```
> Please check CocoaDocs for more information about [Lock-Facebook API](http://cocoadocs.org/docsets/Lock-Facebook)

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

Auth0

## License

Lock-Facebook is available under the MIT license. See the [LICENSE file](LICENSE) for more info.
