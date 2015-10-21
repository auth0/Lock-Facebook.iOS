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
#import <UIKit/UIKit.h>
#import <Lock/A0Strategy.h>
#import <Lock/A0APIClient.h>
#import <Lock/A0IdentityProviderCredentials.h>
#import <Lock/A0AuthParameters.h>

#import "FacebookProvider.h"
#import "LogUtils.h"

static NSString * const DefaultConnectionName = @"facebook";

@interface A0FacebookAuthenticator ()
@property (strong, nonatomic) FacebookProvider *facebook;
@property (copy, nonatomic) NSString *connectionName;
@end

@implementation A0FacebookAuthenticator

- (instancetype)init {
    return [self initWithPermissions:@[]];
}

- (instancetype)initWithPermissions:(nonnull NSArray *)permissions {
    return [self initWithConnectionName:DefaultConnectionName permissions:permissions];
}

- (instancetype)initWithConnectionName:(nonnull NSString *)connectionName permissions:(nonnull NSArray *)permissions {
    return [self initWithConnectionName:connectionName andFacebook:[[FacebookProvider alloc] initWithPermissions:permissions]];
}

- (instancetype)initWithConnectionName:(nonnull NSString *)connectionName andFacebook:(nonnull FacebookProvider *)facebook {
    self = [super init];
    if (self) {
        _facebook = facebook;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        _connectionName = connectionName;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
    A0LogVerbose(@"Notifying FB SDK that app launched with options %@", launchOptions);
    [self.facebook applicationLaunchedWithOptions:launchOptions];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    [self.facebook applicationBecomeActive];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithPermissions:(NSArray *)permissions {
    return [[A0FacebookAuthenticator alloc] initWithPermissions:permissions];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithDefaultPermissions {
    return [self newAuthenticatorWithPermissions:@[]];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithConnectionName:(NSString *)connectionName permissions:(NSArray *)permissions {
    return [[A0FacebookAuthenticator alloc] initWithConnectionName:connectionName permissions:permissions];
}

+ (A0FacebookAuthenticator *)newAuthenticatorWithDefaultPermissionsForConnectionName:(NSString *)connectionName {
    return [self newAuthenticatorWithConnectionName:connectionName permissions:@[]];
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return self.connectionName;
}

- (void)clearSessions {
    [self.facebook clearSession];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    A0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    return [self.facebook handleURL:url sourceApplication:sourceApplication];
}

-(void)authenticateWithParameters:(A0AuthParameters *)parameters
                          success:(void (^)(A0UserProfile *, A0Token *))success
                          failure:(void (^)(NSError *))failure {
    A0LogVerbose(@"Starting Facebook authentication...");
    NSString *connectionName = [self identifier];
    A0APIClient *client = [self apiClient];
    NSArray *permissions = [self permissionsFromParameters:parameters];
    [self.facebook authenticateWithPermissions:permissions
                                      callback:^(NSError *error, NSString *token) {
                                          if (error) {
                                              failure(error);
                                              return;
                                          }
                                          A0IdentityProviderCredentials *credentials = [[A0IdentityProviderCredentials alloc] initWithAccessToken:token];
                                          [client authenticateWithSocialConnectionName:connectionName
                                                                           credentials:credentials
                                                                            parameters:parameters
                                                                               success:success
                                                                               failure:failure];
                                      }];
}

#pragma mark - Utility methods

- (NSArray *)permissionsFromParameters:(A0AuthParameters *)parameters {
    return parameters.connectionScopes[self.identifier];
}

- (A0APIClient *)apiClient {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    return [self.clientProvider apiClient] ?: [A0APIClient sharedClient];
#pragma GCC diagnostic pop
}

@end
