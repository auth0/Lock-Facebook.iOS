// A0FacebookAuthenticator.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
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

#import "A0FacebookAuthenticator.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <libextobjc/EXTScope.h>
#import <Lock/A0Errors.h>
#import <Lock/A0Strategy.h>
#import <Lock/A0Application.h>
#import <Lock/A0APIClient.h>
#import <Lock/A0IdentityProviderCredentials.h>
#import <Lock/A0AuthParameters.h>

#define A0LogError(fmt, ...)
#define A0LogVerbose(fmt, ...)
#define A0LogDebug(fmt, ...)

@interface A0FacebookAuthenticator ()
@property (strong, nonatomic) NSArray *permissions;
@property (strong, nonatomic) FBSDKLoginManager *loginManager;
@end

@implementation A0FacebookAuthenticator

- (instancetype)init {
    return [self initWithPermissions:nil];
}

- (instancetype)initWithPermissions:(NSArray *)permissions {
    self = [super init];
    if (self) {
        if (permissions) {
            NSMutableSet *perms = [[NSMutableSet alloc] initWithArray:permissions];
            [perms addObject:@"public_profile"];
            _permissions = [perms allObjects];
        } else {
            _permissions = @[@"public_profile"];
        }
        _loginManager = [[FBSDKLoginManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
    A0LogVerbose(@"Notifying FB SDK that app launched with options %@", launchOptions);
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    [FBSDKAppEvents activateApp];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithPermissions:(NSArray *)permissions {
    return [[A0FacebookAuthenticator alloc] initWithPermissions:permissions];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithDefaultPermissions {
    return [self newAuthenticatorWithPermissions:nil];
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return A0StrategyNameFacebook;
}

- (void)clearSessions {
    [self.loginManager logOut];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    A0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    return [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] openURL:url sourceApplication:sourceApplication annotation:nil];
}

-(void)authenticateWithParameters:(A0AuthParameters *)parameters success:(void (^)(A0UserProfile *, A0Token *))success failure:(void (^)(NSError *))failure {
    A0LogVerbose(@"Starting Facebook authentication...");
    void (^failureBlock)(NSError *) = failure ?: ^(NSError *error){};
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (accessToken) {
        A0LogDebug(@"Found current FB access token");
        [self executeAuthenticationWithCredentials:[[A0IdentityProviderCredentials alloc] initWithAccessToken:accessToken.tokenString] parameters:parameters success:success failure:failure];
    } else {
        @weakify(self);
        NSArray *permissions = [self permissionsFromParameters:parameters];
            [self.loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                A0LogError(@"Failed to open FB Session with error %@", error);
                failureBlock(error);
            } else if (result.isCancelled) {
                A0LogError(@"FB login was cancelled");
                failureBlock([A0Errors facebookCancelled]);
            } else {
                if (result.declinedPermissions.count != 0) {
                    A0LogDebug(@"User declined some of the permissions %@", result.declinedPermissions);
                    failureBlock([A0Errors facebookCancelled]);
                } else {
                    A0LogDebug(@"Successfully opened FB Session");
                    @strongify(self);
                    A0IdentityProviderCredentials *credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:result.token.tokenString];
                    [self executeAuthenticationWithCredentials:credentials
                                                    parameters:parameters
                                                       success:success
                                                       failure:failure];
                }
            }
        }];
    }
}

#pragma mark - Utility methods

- (NSArray *)permissionsFromParameters:(A0AuthParameters *)parameters {
    NSArray *connectionScopes = parameters.connectionScopes[A0StrategyNameFacebook];
    NSArray *permissions = connectionScopes.count > 0 ? connectionScopes : self.permissions;
    A0LogDebug(@"Facebook Permissions %@", permissions);
    return permissions;
}

- (void)executeAuthenticationWithCredentials:(A0IdentityProviderCredentials *)credentials
                                  parameters:(A0AuthParameters *)parameters
                                     success:(void(^)(A0UserProfile *, A0Token *))success
                                     failure:(void(^)(NSError *))failure {
    A0APIClient *client = [self apiClient];
    [client authenticateWithSocialConnectionName:self.identifier
                                     credentials:credentials
                                      parameters:parameters
                                         success:success
                                         failure:failure];
}

- (A0APIClient *)apiClient {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    return [self.clientProvider apiClient] ?: [A0APIClient sharedClient];
#pragma GCC diagnostic pop
}

@end
