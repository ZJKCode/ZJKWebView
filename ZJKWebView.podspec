#
# Be sure to run `pod lib lint ZJKWebView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZJKWebView'
  s.version          = '0.1.0'
  s.summary          = '一个很有缺的实现实验'
  s.description      = <<-DESC
TODO: 因为组件化需要故实验此次方法
                       DESC

  s.homepage         = 'https://github.com/sweetkk/ZJKWebView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'k721684713@163.com' => 'k721684713@163.com' }
  s.source           = { :git => 'https://github.com/sweetkk/ZJKWebView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'ZJKWebView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZJKWebView' => ['ZJKWebView/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit','Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
