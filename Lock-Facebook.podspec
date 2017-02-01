version = `agvtool mvers -terse1`.strip
Pod::Spec.new do |s|
  s.name             = "Lock-Facebook"
  s.version          = version
  s.summary          = "Facebook Native Authenticaion Plugin for Auth0 Lock 2.0+"
  s.description      = <<-DESC
                      [![Auth0](https://i.cloudup.com/1vaSVATKTL.png)](http://auth0.com)
                      Plugin for [Auth0 Lock](https://github.com/auth0/Lock.iOS-OSX) that handles authentication using Facebook iOS SDK
                       DESC
  s.homepage         = "https://github.com/auth0/Lock-Google.iOS"
  s.license          = "MIT"
  s.author           = { "Auth0" => "support@auth0.com", "Martin Walsh" => "martin.walsh@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/Lock-Facebook.iOS.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/auth0"

  s.platform     = :ios, "9.0"
  s.requires_arc = true
  s.module_name = "LockFacbook"

  s.source_files = "LockFacebook/**/*.{swift}"

  s.dependency "FacebookLogin"
  s.dependency "Auth0", "~> 1.2"
end
