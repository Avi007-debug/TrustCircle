import 'dart:ffi';

import 'ffi/mlange_abi.dart';
import 'types.dart';

final class ZeticMLangeLLMModel {
  ZeticMLangeLLMModel._(this._bindings, this._handle);

  final MlangeBindings _bindings;
  Pointer<Void> _handle;

  static Future<ZeticMLangeLLMModel> create({
    required String personalKey,
    required String name,
    int? version,
    LLMModelMode modelMode = LLMModelMode.runAuto,
    APType? apType,
    LLMQuantType? quantType,
    ModelCacheHandlingPolicy cacheHandlingPolicy =
        CacheHandlingPolicy.removeOverlapping,
    LLMInitOption? initOption,
    LLMKVCacheCleanupPolicy kvCacheCleanupPolicy =
        LLMKVCacheCleanupPolicy.cleanUpOnFull,
    MlangeProgressCallback? onDownload,
    MlangeBindings? bindings,
  }) {
    final resolvedInitOption =
        initOption ?? LLMInitOption(kvCacheCleanupPolicy: kvCacheCleanupPolicy);
    return _load(
      name,
      personalKey: personalKey,
      version: version,
      options: MlangeLLMLoadOptions(
        mode: modelMode,
        apType: apType,
        quantType: quantType,
        cacheHandlingPolicy: cacheHandlingPolicy,
        kvCacheCleanupPolicy: resolvedInitOption.kvCacheCleanupPolicy,
        contextSize: resolvedInitOption.nCtx,
      ),
      onProgress: onDownload,
      bindings: bindings,
    );
  }

  static Future<ZeticMLangeLLMModel> _load(
    String name, {
    required String personalKey,
    int? version,
    MlangeLLMLoadOptions options = const MlangeLLMLoadOptions(),
    MlangeProgressCallback? onProgress,
    MlangeBindings? bindings,
  }) async {
    final nativeBindings = bindings ?? DynamicMlangeBindings();
    final handle = nativeBindings is DynamicMlangeBindings
        ? await nativeBindings.llmModelCreateAsync(
            personalKey,
            name,
            version: version,
            options: options,
            onProgress: onProgress,
          )
        : nativeBindings.llmModelCreate(
            personalKey,
            name,
            version: version,
            options: options,
            onProgress: onProgress,
          );
    return ZeticMLangeLLMModel._(nativeBindings, handle);
  }

  LLMRunResult run(String text) {
    final promptTokens = _bindings.llmModelRun(_requireOpen(), text);
    return MlangeLLMRunResult(status: 0, promptTokens: promptTokens);
  }

  LLMNextTokenResult waitForNextToken() {
    return _bindings.llmModelWaitForNextToken(_requireOpen());
  }

  void cleanUp() {
    _bindings.llmModelCleanUp(_requireOpen());
  }

  bool get isClosed => _handle == nullptr;

  void close() {
    final handle = _requireOpen();
    _bindings.llmModelForceDeinit(handle);
    _handle = nullptr;
  }

  Pointer<Void> _requireOpen() {
    final handle = _handle;
    if (handle == nullptr) {
      throw const MlangeException(-1, 'ZeticMLangeLLMModel is already closed.');
    }
    return handle;
  }
}
