#
# Be sure to run `pod lib lint XMNKeychain.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XMNKeychain'
  s.version          = '0.1.0'
  s.summary          = 'XMNKeychain 使用keychain方式存储用户账号,密码'

  s.homepage         = 'https://github.com/ws00801526/XMNKeychain'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/ws00801526/XMNKeychain.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'XMNKeychain/Classes/**/*'
  s.public_header_files = 'XMNKeychain/Classes/**/*.h'
  s.frameworks = 'Security'
end
