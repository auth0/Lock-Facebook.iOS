// FacebookProvider.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "FacebookProvider.h"
#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Lock/A0Errors.h>
#import "LogUtils.h"

@interface FacebookProvider ()
@property (strong, nonatomic) FBSDKLoginManager *loginManager;
@property (strong, nonatomic) NSArray *permissions;
@property (copy, nonatomic) FBSDKAccessToken *(^currentToken)();
@property (weak, nonatomic) FBSDKApplicationDelegate *applicationDelegate;

- (nonnull instancetype)initWithLoginManager:(FBSDKLoginManager * __nonnull)loginManager
                         applicationDelegate:(FBSDKApplicationDelegate * __nonnull)applicationDelegate
                                 permissions:(NSArray * __nonnull)permissions;
@end

@implementation FacebookProvider

- (nonnull instancetype)initWithPermissions:(NSArray * __nonnull)permissions {
    return [self initWithLoginManager:[[FBSDKLoginManager alloc] init]
                  applicationDelegate:[FBSDKApplicationDelegate sharedInstance]
                          permissions:permissions];
}

- (instancetype)initWithLoginManager:(FBSDKLoginManager *)loginManager
                 applicationDelegate:(FBSDKApplicationDelegate *)applicationDelegate
                         permissions:(NSArray *)permissions {
    self = [super init];
    if (self) {
        _loginManager = loginManager;
        NSMutableSet *set = [[NSMutableSet alloc] initWithArray:permissions];
        [set addObject:@"public_profile"];
        _permissions = [set allObjects];
        _currentToken = ^ {
            return [FBSDKAccessToken currentAccessToken];
        };
        _applicationDelegate = applicationDelegate;
    }
    return self;
}

- (void)authenticateWithPermissions:(NSArray * __nullable)permissions
                           callback:(A0FacebookAuthentication __nonnull)callback {
    NSArray *perms = permissions ? [[NSSet setWithArray:permissions] allObjects] : self.permissions;
    FBSDKAccessToken *token = self.currentToken();
    if ([token.expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        A0LogDebug(@"User is already athenticated with Facebook. Returning cached token.");
        callback(nil, token.tokenString);
        return;
    }
    A0LogVerbose(@"Starting authentication with permissions %@", perms);
    [self.loginManager logInWithReadPermissions:perms fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            A0LogError(@"Facebook login failed with error %@", error);
            callback(error, nil);
            return;
        }
        if (result.isCancelled || result.declinedPermissions.count > 0) {
            A0LogError(@"Facebook login was cancelled. Declined permissions %@", result.declinedPermissions);
            callback([A0Errors facebookCancelled], nil);
            return;
        }
        A0LogDebug(@"Authenticated user %@ with the following permissions %@", result.token.userID, result.grantedPermissions);
        callback(nil, result.token.tokenString);
    }];
}

- (void)clearSession {
    A0LogDebug(@"Cleaning Facebook session");
    [self.loginManager logOut];
}

- (BOOL)handleURL:(NSURL * __nonnull)url sourceApplication:(NSString * __nonnull)sourceApplication {
    return [self.applicationDelegate application:[UIApplication sharedApplication] openURL:url sourceApplication:sourceApplication annotation:nil];
}

- (void)applicationBecomeActive {
    [FBSDKAppEvents activateApp];
}

- (void)applicationLaunchedWithOptions:(NSDictionary * __nonnull)launchOptions {
    [self.applicationDelegate application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launchOptions];
}
@end

