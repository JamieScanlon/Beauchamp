Pod::Spec.new do |spec|
  spec.name = "beauchamp"
  spec.version = "1.0.0"
  spec.summary = "A behavior prediction engine."
  spec.homepage = "https://github.com/JamieScanlon/beauchamp"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Jamie Scanlon" => 'jamie@tenthlettermade.com' }
  spec.social_media_url = "http://twitter.com/jamiescanlon"

  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/JamieScanlon/beauchamp.git", tag: "v#{spec.version}" }
  spec.source_files = "beauchamp/**/*.swift"
end