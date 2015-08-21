// A0FacebookAuthenticator.h
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

#import <Foundation/Foundation.h>
#import <Lock/A0BaseAuthenticator.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `A0FacebookAuthentication` performs Facebook authentication of a user using Facebook iOS SDK.
 */
@interface A0FacebookAuthenticator : A0BaseAuthenticator

/**
 *  Creates a new instance
 *
 *  @param permissions list of permissions to ask the user when authenticating application
 *
 *  @return a new instance
 */
+ (A0FacebookAuthenticator *)newAuthenticatorWithPermissions:(NSArray *)permissions;

/**
 *  Creates a new instance with the default permissions ("public_profile").
 *
 *  @return a new instance
 */
+ (A0FacebookAuthenticator *)newAuthenticatorWithDefaultPermissions;

/**
 *  Creates a new instance of the authenticator for a custom Facebook connection
 *
 *  @param connectionName of the custom facebook connection
 *  @param permissions list of permissions to ask the user when authenticating application
 *
 *  @return a new instance
 */
+ (A0FacebookAuthenticator *)newAuthenticatorWithConnectionName:(NSString *)connectionName permissions:(NSArray *)permissions;

/**
 *  Creates a new instance with the default permissions ("public_profile") for a custom Facebook connection.
 *
 *  @param connectionName of the custom facebook connection
 *
 *  @return a new instance
 */
+ (A0FacebookAuthenticator *)newAuthenticatorWithDefaultPermissionsForConnectionName:(NSString *)connectionName;

@end

NS_ASSUME_NONNULL_END