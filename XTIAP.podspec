Pod::Spec.new do |s|
  s.name             = 'XTIAP'
  s.version          = '1.0.2'
  s.summary          = 'A short description of XTIAP.'
  s.description      = 'iOS iap util (Objective-C)'
  s.homepage         = 'https://github.com/akateason/XTIAP'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teason' => 'akateason@qq.com' }
  s.source           = { :git => 'https://github.com/akateason/XTIAP.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'XTIAP/iap/**/*'
  s.public_header_files = 'XTIAP/iap/**/*.h'  

  # s.resource_bundles = {
  #   'XTIAP' => ['XTIAP/Assets/*.png']
  # }

  #s.subspec 'XTIAP' do | sm |
      #sm.source_files = 'XTIAP/ZYSubModule/**/*'
      #sm.dependency 'AFNetworking', '~> 2.3'
  #end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'XTBase'
  s.dependency 'XTReq'
  
end
