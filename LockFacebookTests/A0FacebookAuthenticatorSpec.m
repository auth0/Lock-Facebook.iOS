// A0FacebookAuthenticatorSpec.m
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

@import Specta;
@import Expecta;
@import FBSDKLoginKit;
@import FBSDKCoreKit;
@import OCMockito;
@import OCHamcrest;
@import Lock;

#import "FacebookProvider.h"
#import "A0FacebookAuthenticator.h"

#define mock(clazz) MKTMock(clazz)
#define verify(mock) MKTVerify(mock)
#define verifyCount(mock, count) MKTVerifyCount(mock, count)
#define given(call) MKTGiven(call)
#define never() MKTNever()
#define anything() HC_anything()
#define notNil() HC_notNilValue()

@interface A0FacebookAuthenticator (Testing)
- (instancetype)initWithFacebook:(nonnull FacebookProvider *)facebook;
- (void)applicationActiveNotification:(NSNotification *)notification;
@end

SpecBegin(A0FacebookAuthenticator)

__block A0FacebookAuthenticator *authenticator;
__block FacebookProvider *provider;
__block A0APIClient *client;
__block A0Lock *lock;

beforeEach(^{
    provider = mock(FacebookProvider.class);
    client = mock(A0APIClient.class);
    lock = mock(A0Lock.class);
    [given(lock.apiClient) willReturn:client];
    authenticator = [[A0FacebookAuthenticator alloc] initWithFacebook:provider];
    authenticator.clientProvider = lock;
});

describe(@"lifecycle", ^{

    it(@"should delegate handleURL", ^{
        NSURL *url = mock(NSURL.class);
        NSString *app = @"MyApp";
        [authenticator handleURL:url sourceApplication:app];
        [verify(provider) handleURL:url sourceApplication:app];
    });

    it(@"should delegate app launched", ^{
        [authenticator applicationLaunchedWithOptions:@{}];
        [verify(provider) applicationLaunchedWithOptions:@{}];
    });

    it(@"should delegate clear sessions", ^{
        [authenticator clearSessions];
        [verify(provider) clearSession];
    });

    it(@"should delegate app become active", ^{
        NSNotification *notification = mock(NSNotification.class);
        [authenticator applicationActiveNotification:notification];
        [verify(provider) applicationBecomeActive];
    });
});

describe(@"authentication", ^{

    __block A0AuthParameters *parameters;
    __block NSString *fbToken;

    beforeEach(^{
        parameters = [A0AuthParameters newDefaultParams];
        fbToken = [[NSUUID UUID] UUIDString];
    });

    it(@"should authenticate using provider", ^{
        [authenticator authenticateWithParameters:parameters
                                          success:^(A0UserProfile *profile, A0Token *token) {}
                                          failure:^(NSError *error) {}];
        [verify(provider) authenticateWithPermissions:nil callback:anything()];
    });

    it(@"should authenticate using provider with permissions in parameters", ^{
        NSArray *permissions = @[@"public_profile", @"email", @"user_likes"];
        A0AuthParameters *parameters = [A0AuthParameters newDefaultParams];
        [parameters setConnectionScopes:@{
                                          @"facebook": permissions,
                                          }];
        [authenticator authenticateWithParameters:parameters
                                          success:^(A0UserProfile *profile, A0Token *token) {}
                                          failure:^(NSError *error) {}];
        [verify(provider) authenticateWithPermissions:permissions callback:anything()];
    });

    it(@"should call failure when it fails", ^{
        waitUntil(^(DoneCallback done) {
            [authenticator authenticateWithParameters:parameters
                                              success:^(A0UserProfile *profile, A0Token *token) {
                                                  failure(@"Must be a failed auth attempt");
                                                  done();
                                              }
                                              failure:^(NSError *error) {
                                                  expect(error).toNot.beNil();
                                                  done();
                                              }];
            MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
            [verify(provider) authenticateWithPermissions:nil callback:[captor capture]];
            A0FacebookAuthentication block = [captor value];
            block(mock(NSError.class), nil);
            [verifyCount(client, never()) authenticateWithSocialConnectionName:anything()
                                                                   credentials:anything()
                                                                    parameters:anything()
                                                                       success:anything()
                                                                       failure:anything()];
        });
    });

    it(@"should authenticate against Auth0", ^{
        [given([client authenticateWithSocialConnectionName:@"facebook"
                                                credentials:notNil()
                                                 parameters:parameters
                                                    success:notNil()
                                                    failure:notNil()])
         willDo:^id(NSInvocation *invocation) {
             NSArray *args = [invocation mkt_arguments];
             A0IdentityProviderCredentials *creds = args[1];
             expect(creds.accessToken).to.equal(fbToken);
             A0APIClientAuthenticationSuccess success = args[3];
             A0UserProfile *profile = mock(A0UserProfile.class);
             A0Token *token = mock(A0Token.class);
             success(profile, token);
             return nil;
         }];

        waitUntil(^(DoneCallback done) {
            [authenticator authenticateWithParameters:parameters
                                              success:^(A0UserProfile *profile, A0Token *token) {
                                                  expect(profile).toNot.beNil();
                                                  expect(token).toNot.beNil();
                                                  done();
                                              }
                                              failure:^(NSError *error) {
                                                  failure(@"Must be a success attempt");
                                                  done();
                                              }];
            MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
            [verify(provider) authenticateWithPermissions:nil callback:[captor capture]];
            A0FacebookAuthentication block = [captor value];
            block(nil, fbToken);
        });
    });

    it(@"should call failure with errors from Auth0", ^{
        [given([client authenticateWithSocialConnectionName:@"facebook"
                                                credentials:notNil()
                                                 parameters:parameters
                                                    success:notNil()
                                                    failure:notNil()])
         willDo:^id(NSInvocation *invocation) {
             NSArray *args = [invocation mkt_arguments];
             A0APIClientError failed = args[4];
             failed(mock(NSError.class));
             return nil;
         }];

        waitUntil(^(DoneCallback done) {
            [authenticator authenticateWithParameters:parameters
                                              success:^(A0UserProfile *profile, A0Token *token) {
                                                  failure(@"Must be a failed auth attempt");
                                                  done();
                                              }
                                              failure:^(NSError *error) {
                                                  expect(error).toNot.beNil();
                                                  done();
                                              }];
            MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
            [verify(provider) authenticateWithPermissions:nil callback:[captor capture]];
            A0FacebookAuthentication block = [captor value];
            block(nil, fbToken);
        });
    });

});

SpecEnd