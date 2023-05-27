#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint uni_sdk_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'uni_sdk_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  # s.resources = 'Assets/Resources/*'
  s.resources = ["Assets/Resources/*.js", "Assets/Resources/*.ttf", "Assets/Resources/*.bundle"]
  #头文件
  s.public_header_files = 'Classes/Headers/**/*.h'
  #.a文件
  s.vendored_libraries = 'Core/Libs/*.a'
  #framework
  s.vendored_frameworks = 'Core/Libs/*.framework'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.swift_version = '5.0'
  s.frameworks = 'JavaScriptCore', 'CoreMedia', 'MediaPlayer', 'AVFoundation', 'AVKit', 'GLKit', 'OpenGLES', 'CoreText', 'QuartzCore', 'CoreGraphics', 'QuickLook', 'CoreTelephony'
  s.libraries = 'c++', 'iconv'
end
