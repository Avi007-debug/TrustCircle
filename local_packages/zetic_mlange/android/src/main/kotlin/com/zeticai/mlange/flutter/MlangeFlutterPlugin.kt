package com.zeticai.mlange.flutter

import com.zeticai.mlange.core.ffi.MlangeFfiBridge
import io.flutter.embedding.engine.plugins.FlutterPlugin

class MlangeFlutterPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        System.loadLibrary("zetic_mlange_flutter_bridge")
        MlangeFfiBridge.initialize(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit
}
