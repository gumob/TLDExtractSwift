Pod::Spec.new do |s|

  s.name                   = "TLDExtract"
  s.version                = "1.0.0"
  s.summary                = "A Pure Swift library for extracting TLD supporting iOS, macOS, and tvOS."
  s.homepage               = "https://github.com/gumob/TLDExtractSwift"
  s.license                = { :type => "MIT", :file => "LICENSE" }
  s.author                 = { "gumob" => "hello@gumob.com" }
  s.frameworks             = 'Foundation'
  s.requires_arc           = true
  s.source                 = { :git => "https://github.com/gumob/TLDExtractSwift.git", :tag => "#{s.version}" }
  s.source_files           = "Source/*.{swift}"
  s.resources              = "Resources/*.dat"
  s.ios.deployment_target  = "9.3"
  s.osx.deployment_target  = "10.12"
  s.tvos.deployment_target = "12.0"
  s.swift_version          = '4.2'

  s.dependency "Punycode", "~> 1.0.0"

end
