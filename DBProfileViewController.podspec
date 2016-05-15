Pod::Spec.new do |s|
  s.name             = 'DBProfileViewController'
  s.version          = '2.0.3'
  s.summary          = 'A customizable library for creating stunning user profiles.'
  s.homepage         = 'https://github.com/devonboyer/DBProfileViewController'
  s.license          = 'MIT'
  s.author           = { 'Devon Boyer' => 'hello@devonboyer.com' }
  s.source           = { :git => "https://github.com/devonboyer/DBProfileViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/devboyer'
  s.requires_arc = true
  s.platform     = :ios, '7.0'

  s.source_files = 'DBProfileViewController/**/*'
  s.public_header_files = 'DBProfileViewController/**/*.h'
  s.private_header_files = 'DBProfileViewController/Private/*.h'
  
  s.resource_bundle = { 'DBProfileViewController' => 'Assets/*.png' }
  
  s.dependency 'FXBlurView', '~> 1.6.4'
end
