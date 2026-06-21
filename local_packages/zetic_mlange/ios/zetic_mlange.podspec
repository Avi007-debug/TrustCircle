Pod::Spec.new do |s|
  zetic_mlange_ios_version = '1.8.0'
  zetic_mlange_github = 'https://github.com/zetic-ai/ZeticMLangeiOS'
  zetic_mlange_xcframework_url = "#{zetic_mlange_github}/releases/download/#{zetic_mlange_ios_version}/ZeticMLange.xcframework.zip"
  zetic_mlange_xcframework = 'ZeticMLange.xcframework'

  s.name             = 'zetic_mlange'
  s.version          = '1.8.1'
  s.summary          = 'Flutter FFI SDK for ZeticMLange.'
  s.description      = 'Flutter FFI SDK for running ZeticMLange on-device AI models on Android and iOS.'
  s.homepage         = 'https://docs.zetic.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ZETIC.ai' => 'contact@zetic.ai' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.prepare_command = <<~CMD
    set -euo pipefail

    if [ ! -d "#{zetic_mlange_xcframework}" ]; then
      curl -fL "#{zetic_mlange_xcframework_url}" -o ZeticMLange.xcframework.zip
      rm -rf "#{zetic_mlange_xcframework}"
      unzip -q ZeticMLange.xcframework.zip
      rm -f ZeticMLange.xcframework.zip
    fi
  CMD
  s.vendored_frameworks = zetic_mlange_xcframework
  s.frameworks = 'Accelerate'
  s.static_framework = true
  s.dependency 'Flutter'
  s.platform         = :ios, '16.6'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
