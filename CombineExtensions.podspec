Pod::Spec.new do |s|
  s.name             = 'CombineExtensions'
  s.version          = '0.1.0'
  s.summary          = 'Extensions adding the Combine missing parts.'

  s.description      = <<-DESC
  Extensions adding the Combine missing parts.
  DESC

  s.homepage         = 'https://github.com/bitomule/CombineExtensions'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bitomule' => 'bitomule@gmail.com' }
  s.source           = { :git => 'https://github.com/bitomule/CombineExtensions.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bitomule'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/Classes/**/*'
  s.frameworks = 'Combine'
end
