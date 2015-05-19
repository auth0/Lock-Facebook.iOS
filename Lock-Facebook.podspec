Pod::Spec.new do |s|
  s.name             = "Lock-Facebook"
  s.version          = "2.0.0"
  s.summary          = "Facebook Native Integration for Auth0 Lock"
  s.description      = <<-DESC
                      [![Auth0](https://i.cloudup.com/1vaSVATKTL.png)](http://auth0.com)
                      Plugin for [Auth0 Lock](https://github.com/auth0/Lock.iOS-OSX) that handles authentication using Facebook iOS SDK.
                       DESC
  s.homepage         = "https://github.com/auth0/Lock-Facebook.iOS"
  s.license          = 'MIT'
  s.author           = { "Auth0" => "support@auth0.com", "Hernan Zalazar" => "hernan@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Lock-Facebook.iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'Pod/Classes/*.h'
  s.source_files = 'Pod/Classes/*.{h,m}'
  s.module_name = 'LockFacebook'

  s.dependency 'FBSDKLoginKit', '~> 4.0'
  s.dependency 'FBSDKCoreKit', '~> 4.0'
  s.dependency 'Lock/Core', '~> 1.11'
  s.dependency 'CocoaLumberjack', '~> 2.0'
end
