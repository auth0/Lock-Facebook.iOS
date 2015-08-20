// A0FacebookProvider.m
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

#import "A0FacebookProvider.h"
#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <Lock/A0Errors.h>

@interface A0FacebookProvider ()
@property (strong, nonatomic) FBSDKLoginManager *loginManager;
@property (strong, nonatomic) NSArray *permissions;
@property (copy, nonatomic) FBSDKAccessToken *(^currentToken)();

- (nonnull instancetype)initWithLoginManager:(FBSDKLoginManager * __nonnull)loginManager permissions:(NSArray * __nonnull)permissions;
@end

@implementation A0FacebookProvider

- (nonnull instancetype)initWithPermissions:(NSArray * __nonnull)permissions {
    return [self initWithLoginManager:[[FBSDKLoginManager alloc] init] permissions:permissions];
}

- (instancetype)initWithLoginManager:(FBSDKLoginManager *)loginManager permissions:(NSArray *)permissions {
    self = [super init];
    if (self) {
        _loginManager = loginManager;
        NSMutableSet *set = [[NSMutableSet alloc] initWithArray:permissions];
        [set addObject:@"public_profile"];
        _permissions = [set allObjects];
        _currentToken = ^ {
            return [FBSDKAccessToken currentAccessToken];
        };
    }
    return self;
}

- (void)authenticateWithPermissions:(NSArray * __nullable)permissions callback:(A0FacebookAuthentication __nonnull)callback {
    FBSDKAccessToken *token = self.currentToken();
    if ([token.expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        callback(nil, token.tokenString);
        return;
    }
    NSArray *perms = permissions ? [[NSSet setWithArray:permissions] allObjects] : self.permissions;
    [self.loginManager logInWithReadPermissions:perms handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            callback(error, nil);
            return;
        }
        if (result.isCancelled || result.declinedPermissions.count > 0) {
            callback([A0Errors facebookCancelled], nil);
            return;
        }
        callback(nil, result.token.tokenString);
    }];
}

@end

