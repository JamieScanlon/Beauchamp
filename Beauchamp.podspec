Pod::Spec.new do |spec|
  spec.name = "Beauchamp"
  spec.version = "0.2.0"
  spec.summary = "A behavior prediction engine."
  spec.homepage = "https://github.com/JamieScanlon/Beauchamp"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Jamie Scanlon" => 'jamie@tenthlettermade.com' }
  spec.social_media_url = "http://twitter.com/jamiescanlon"

  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/JamieScanlon/Beauchamp.git", tag: "v#{spec.version}" }
  spec.source_files = "Beauchamp/Beauchamp/*.swift"
end