#
# Be sure to run `pod lib lint MPWebview.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MPWebview'
  s.version          = '0.0.3'
  s.summary          = 'A short description of MPWebview.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tian@marcopolos.co.jp/MPWebview'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tian@marcopolos.co.jp' => 'lintong@withease.cn' }
  s.source           = { :git => 'https://github.com/tian@marcopolos.co.jp/MPWebview.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MPWebview/Classes/*'
  
   s.resource_bundles = {
     'MPWebview' => ['MPWebview/Assets/*']
   }
   s.swift_version = '4.0'

#   s.public_header_files = 'Pod/Classes/MPWebview.swift'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SVGKit'
  s.dependency 'lottie-ios'
  s.dependency 'Masonry'
end
