// A0FacebookProviderSpec.m
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

#import "A0FacebookProvider.h"

#define mock(clazz) MKTMock(clazz)
#define verify(mock) MKTVerify(mock)
#define verifyCount(mock, count) MKTVerifyCount(mock, count)
#define given(call) MKTGiven(call)
#define never() MKTNever()
#define anything() HC_anything()

@interface A0FacebookProvider (Testing)
@property (strong, nonatomic) FBSDKLoginManager *loginManager;
@property (strong, nonatomic) NSArray *permissions;
@property (copy, nonatomic) FBSDKAccessToken *(^currentToken)();
@property (weak, nonatomic) FBSDKApplicationDelegate *applicationDelegate;
- (nonnull instancetype)initWithLoginManager:(FBSDKLoginManager * __nonnull)loginManager
                         applicationDelegate:(FBSDKApplicationDelegate * __nonnull)applicationDelegate
                                 permissions:(NSArray * __nonnull)permissions;
@end

SpecBegin(A0FacebookProvider)

FBSDKAccessToken *(^fbExpiredToken)() = ^{
    FBSDKAccessToken *fbToken = mock(FBSDKAccessToken.class);
    [given(fbToken.tokenString) willReturn:[[NSUUID UUID] UUIDString]];
    [given(fbToken.expirationDate) willReturn:[NSDate dateWithTimeIntervalSinceNow:-1000]];
    return fbToken;
};

FBSDKAccessToken *(^fbTokenWithToken)(NSString *) = ^(NSString *token) {
    FBSDKAccessToken *fbToken = mock(FBSDKAccessToken.class);
    [given(fbToken.tokenString) willReturn:token];
    [given(fbToken.expirationDate) willReturn:[NSDate dateWithTimeIntervalSinceNow:1000]];
    return fbToken;
};

__block A0FacebookProvider *facebook;
__block FBSDKLoginManager *loginManager;
__block FBSDKApplicationDelegate *delegate;

beforeEach(^{
    loginManager = mock(FBSDKLoginManager.class);
    delegate = mock(FBSDKApplicationDelegate.class);
});

describe(@"initialisation", ^{

    sharedExamples(@"valid provider", ^(NSDictionary *data) {
        __block FBSDKLoginManager *manager;
        __block NSArray *permissions;
        __block A0FacebookProvider *provider;

        beforeEach(^{
            manager = data[@"manager"];
            permissions = data[@"permissions"];
            provider = [[A0FacebookProvider alloc] initWithLoginManager:manager applicationDelegate:delegate permissions:permissions];
        });

        it(@"should store manager", ^{
            expect(provider.loginManager).to.equal(manager);
        });

        it(@"should store permissions", ^{
            expect(provider.permissions).to.beSupersetOf(permissions);
        });

        it(@"should have default permission", ^{
            expect(provider.permissions).to.contain(@"public_profile");
        });

        it(@"should have only unique permissions", ^{
            NSCountedSet *set = [[NSCountedSet alloc] initWithArray:provider.permissions];
            for(NSString *permission in [set allObjects]) {
                expect([set countForObject:permission]).to.equal(1);
            }
        });

        it(@"should have a current token block", ^{
            expect(provider.currentToken).toNot.beNil();
        });

    });

    itShouldBehaveLike(@"valid provider", ^{
        return @{
                 @"manager": loginManager,
                 @"permissions": @[@"public_profile", @"email"],
                 };
    });

    itShouldBehaveLike(@"valid provider", ^{
        return @{
                 @"manager": loginManager,
                 @"permissions": @[@"email"],
                 };
    });

    itShouldBehaveLike(@"valid provider", ^{
        return @{
                 @"manager": loginManager,
                 @"permissions": @[],
                 };
    });


    itShouldBehaveLike(@"valid provider", ^{
        return @{
                 @"manager": loginManager,
                 @"permissions": @[@"public_profile", @"email", @"email"],
                 };
    });

});

describe(@"authenticate", ^{

    __block NSString *token = @"opaque token";
    __block NSArray *defaultPermissions = @[@"public_profile"];

    FBSDKLoginManagerLoginResult *(^resultWithToken)(NSString *) = ^(NSString *token) {
        FBSDKLoginManagerLoginResult *result = mock(FBSDKLoginManagerLoginResult.class);
        FBSDKAccessToken *fbToken = fbTokenWithToken(token);
        [given(result.token) willReturn:fbToken];
        return result;
    };

    FBSDKLoginManagerLoginResult *(^cancelledResult)() = ^ {
        FBSDKLoginManagerLoginResult *result = mock(FBSDKLoginManagerLoginResult.class);
        [given(result.isCancelled) willReturn:@YES];
        return result;
    };

    FBSDKLoginManagerLoginResult *(^declinedPermissionsResult)(NSArray *permissions) = ^(NSArray *permissions) {
        FBSDKLoginManagerLoginResult *result = mock(FBSDKLoginManagerLoginResult.class);
        [given(result.declinedPermissions) willReturn:[NSSet setWithArray:permissions]];
        return result;
    };

    void(^invokeHandler)(FBSDKLoginManagerLoginResult *, NSError *) = ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
        [verify(loginManager) logInWithReadPermissions:defaultPermissions handler:[captor capture]];
        FBSDKLoginManagerRequestTokenHandler block = [captor value];
        block(result, error);
    };

    beforeEach(^{
        facebook = [[A0FacebookProvider alloc] initWithLoginManager:loginManager
                                                applicationDelegate:delegate
                                                        permissions:defaultPermissions];
        facebook.currentToken = ^FBSDKAccessToken *{ return nil; };
    });

    it(@"should authenticate with no permissions", ^{
        [facebook authenticateWithPermissions:nil callback:^(NSError *error, NSString *token) {}];
        [verify(loginManager) logInWithReadPermissions:defaultPermissions handler:HC_notNilValue()];
    });

    it(@"should override default permissoins", ^{
        NSArray *permissions = @[@"public_profile", @"email", @"user_likes"];
        [facebook authenticateWithPermissions:permissions callback:^(NSError *error, NSString *token) {}];
        [verify(loginManager) logInWithReadPermissions:permissions handler:HC_notNilValue()];
    });

    it(@"should pass along token on success", ^{
        FBSDKLoginManagerLoginResult *result = resultWithToken(token);
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).to.beNil();
                                             expect(token).to.equal(token);
                                             done();
                                         }];
            invokeHandler(result, nil);
        });
    });

    it(@"should execute login with expired cached token", ^{
        facebook.currentToken = ^FBSDKAccessToken *{ return fbExpiredToken(); };
        FBSDKLoginManagerLoginResult *result = resultWithToken(token);
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).to.beNil();
                                             expect(token).to.equal(token);
                                             done();
                                         }];
            invokeHandler(result, nil);
        });
    });

    it(@"should use cached token if valid", ^{
        facebook.currentToken = ^FBSDKAccessToken *{ return fbTokenWithToken(token); };
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).to.beNil();
                                             expect(token).to.equal(token);
                                             [verifyCount(loginManager, never()) logInWithReadPermissions:anything()
                                                                                                  handler:anything()];
                                             done();
                                         }];
        });
    });

    it(@"should invoke callback with error only when it fails", ^{
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).toNot.beNil();
                                             expect(token).to.beNil();
                                             done();
                                         }];
            invokeHandler(nil, mock(NSError.class));
        });
    });

    it(@"should return cancelled error when user cancelled login", ^{
        FBSDKLoginManagerLoginResult *result = cancelledResult();
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).toNot.beNil();
                                             expect(error.code).to.equal(A0ErrorCodeFacebookCancelled);
                                             expect(error.domain).to.equal(@"com.auth0");
                                             expect(token).to.beNil();
                                             done();
                                         }];
            invokeHandler(result, nil);
        });
    });

    it(@"should return cancelled error when user declined at least one permission", ^{
        FBSDKLoginManagerLoginResult *result = declinedPermissionsResult(@[defaultPermissions.firstObject]);
        waitUntil(^(DoneCallback done) {
            [facebook authenticateWithPermissions:nil
                                         callback:^(NSError *error, NSString *token) {
                                             expect(error).toNot.beNil();
                                             expect(error.code).to.equal(A0ErrorCodeFacebookCancelled);
                                             expect(error.domain).to.equal(@"com.auth0");
                                             expect(token).to.beNil();
                                             done();
                                         }];
            invokeHandler(result, nil);
        });
    });

});

describe(@"lifecycle", ^{

    beforeEach(^{
        facebook = [[A0FacebookProvider alloc] initWithLoginManager:loginManager
                                                applicationDelegate:delegate
                                                        permissions:@[]];
    });

    it(@"should logout", ^{
        [facebook clearSession];
        [verify(loginManager) logOut];
    });

    it(@"should handle URL", ^{
        NSURL *url = mock(NSURL.class);
        NSString *sourceApplication = @"MyApp";
        [facebook handleURL:url sourceApplication:sourceApplication];
        [verify(delegate) application:HC_anything() openURL:url sourceApplication:sourceApplication annotation:anything()];
    });

    it(@"should notify of app launch", ^{
        NSDictionary *options = @{};
        [facebook applicationLaunchedWithOptions:options];
        [verify(delegate) application:anything() didFinishLaunchingWithOptions:options];
    });
});
SpecEnd