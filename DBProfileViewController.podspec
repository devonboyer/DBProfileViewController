Pod::Spec.new do |s|
  s.name             = "DBProfileViewController"
  s.version          = "1.0.2"
  s.summary          = "A customizable library for creating stunning user profiles."
  s.homepage         = "https://github.com/devonboyer/DBProfileViewController"
  s.license          = 'MIT'
  s.author           = { "Devon Boyer" => "hello@devonboyer.com" }
  s.source           = { :git => "https://github.com/devonboyer/DBProfileViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/devboyer'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Source/**/*'
  s.resource_bundles = {
    'DBProfileViewController' => ['Assets/*.png']
  }

  s.public_header_files = 'Source/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'FXBlurView', '~> 1.6.4'
end
