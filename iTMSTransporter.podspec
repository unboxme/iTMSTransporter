
Pod::Spec.new do |s|
  s.name             = 'iTMSTransporter'
  s.version          = '0.0.1'
  s.summary          = 'Easy to use iTMSTransporter wrapper for macOS '
  s.homepage         = 'https://github.com/unboxme/iTMSTransporter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pavel Puzyrev' => 'puzyrev.pavel@yahoo.com' }
  s.source           = { :git => 'https://github.com/unboxme/iTMSTransporter.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target = "10.10"
  s.swift_versions = "5"

  s.source_files = 'Transporter/**/*.{swift}'
end
