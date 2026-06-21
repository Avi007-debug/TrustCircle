import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../tensor.dart';
import '../types.dart';

const int mlangeStatusOk = 0;
const int mlangeStatusUnsupported = 2;

final class MlangeNativeTensor extends Struct {
  external Pointer<Uint8> data;

  @IntPtr()
  external int byteLength;

  @Int32()
  external int dtype;

  @Int32()
  external int rank;

  external Pointer<Int64> shape;
}

abstract interface class MlangeBindings {
  Pointer<Void> modelCreate(String modelKeyOrPath, MlangeLoadOptions options);

  Pointer<Void> modelCreateRemote(
    String personalKey,
    String name, {
    int? version,
    MlangeLoadOptions options,
    MlangeProgressCallback? onProgress,
  });

  Pointer<Void> hfModelCreate(
    String repoId, {
    String? userAccessToken,
    String? manifestDir,
    int index,
    CacheHandlingPolicy cacheHandlingPolicy,
  });

  void modelRelease(Pointer<Void> handle);

  void modelRun(Pointer<Void> handle);

  int modelInputCount(Pointer<Void> handle);

  int modelOutputCount(Pointer<Void> handle);

  Tensor modelInputAt(Pointer<Void> handle, int index);

  Tensor modelOutputAt(Pointer<Void> handle, int index);

  String lastError(Pointer<Void> handle);

  Pointer<Void> llmModelCreate(
    String personalKey,
    String name, {
    int? version,
    MlangeLLMLoadOptions options,
    MlangeProgressCallback? onProgress,
  });

  void llmModelRelease(Pointer<Void> handle);

  int llmModelRun(Pointer<Void> handle, String prompt);

  MlangeNextToken llmModelWaitForNextToken(Pointer<Void> handle);

  void llmModelCleanUp(Pointer<Void> handle);

  void llmModelForceDeinit(Pointer<Void> handle);

  String llmLastError(Pointer<Void> handle);
}

final class DynamicMlangeBindings implements MlangeBindings {
  DynamicMlangeBindings([DynamicLibrary? library])
    : _library = library ?? _openDefaultLibrary() {
    _create = _library.lookupFunction<_ModelCreateNative, _ModelCreateDart>(
      'mlange_model_create',
    );
    _createRemote = _lookupOptional(
      () => _library
          .lookupFunction<_ModelCreateRemoteNative, _ModelCreateRemoteDart>(
            'mlange_model_create_remote',
          ),
    );
    _hfCreate = _lookupOptional(
      () => _library.lookupFunction<_HfModelCreateNative, _HfModelCreateDart>(
        'mlange_hf_model_create',
      ),
    );
    _release = _library.lookupFunction<_ModelReleaseNative, _ModelReleaseDart>(
      'mlange_model_release',
    );
    _run = _library.lookupFunction<_ModelRunNative, _ModelRunDart>(
      'mlange_model_run',
    );
    _inputCount = _library.lookupFunction<_ModelCountNative, _ModelCountDart>(
      'mlange_model_input_count',
    );
    _outputCount = _library.lookupFunction<_ModelCountNative, _ModelCountDart>(
      'mlange_model_output_count',
    );
    _inputAt = _library.lookupFunction<_TensorAtNative, _TensorAtDart>(
      'mlange_model_input_at',
    );
    _outputAt = _library.lookupFunction<_TensorAtNative, _TensorAtDart>(
      'mlange_model_output_at',
    );
    _lastError = _library.lookupFunction<_LastErrorNative, _LastErrorDart>(
      'mlange_model_last_error',
    );
    _llmCreate = _lookupOptional(
      () => _library.lookupFunction<_LLMCreateNative, _LLMCreateDart>(
        'mlange_llm_model_create',
      ),
    );
    _llmRelease = _lookupOptional(
      () => _library.lookupFunction<_ModelReleaseNative, _ModelReleaseDart>(
        'mlange_llm_model_release',
      ),
    );
    _llmRun = _lookupOptional(
      () => _library.lookupFunction<_LLMRunNative, _LLMRunDart>(
        'mlange_llm_model_run',
      ),
    );
    _llmWaitForNextToken = _lookupOptional(
      () => _library
          .lookupFunction<_LLMWaitForNextTokenNative, _LLMWaitForNextTokenDart>(
            'mlange_llm_model_wait_for_next_token',
          ),
    );
    _llmCleanUp = _lookupOptional(
      () => _library.lookupFunction<_ModelRunNative, _ModelRunDart>(
        'mlange_llm_model_cleanup',
      ),
    );
    _llmForceDeinit = _lookupOptional(
      () => _library.lookupFunction<_ModelReleaseNative, _ModelReleaseDart>(
        'mlange_llm_model_force_deinit',
      ),
    );
    _llmLastError = _lookupOptional(
      () => _library.lookupFunction<_LastErrorNative, _LastErrorDart>(
        'mlange_llm_model_last_error',
      ),
    );
  }

  final DynamicLibrary _library;
  late final _ModelCreateDart _create;
  late final _ModelCreateRemoteDart? _createRemote;
  late final _HfModelCreateDart? _hfCreate;
  late final _ModelReleaseDart _release;
  late final _ModelRunDart _run;
  late final _ModelCountDart _inputCount;
  late final _ModelCountDart _outputCount;
  late final _TensorAtDart _inputAt;
  late final _TensorAtDart _outputAt;
  late final _LastErrorDart _lastError;
  late final _LLMCreateDart? _llmCreate;
  late final _ModelReleaseDart? _llmRelease;
  late final _LLMRunDart? _llmRun;
  late final _LLMWaitForNextTokenDart? _llmWaitForNextToken;
  late final _ModelRunDart? _llmCleanUp;
  late final _ModelReleaseDart? _llmForceDeinit;
  late final _LastErrorDart? _llmLastError;
  @override
  Pointer<Void> modelCreate(String modelKeyOrPath, MlangeLoadOptions options) {
    final modelKey = modelKeyOrPath.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    try {
      final status = _create(
        modelKey.cast(),
        options.mode.nativeValue,
        options.quantType?.index ?? -1,
        options.target?.nativeValue ?? -1,
        options.apType.nativeValue,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(modelKey);
      calloc.free(outHandle);
    }
  }

  @override
  Pointer<Void> modelCreateRemote(
    String personalKey,
    String name, {
    int? version,
    MlangeLoadOptions options = const MlangeLoadOptions(),
    MlangeProgressCallback? onProgress,
  }) {
    final createRemote = _createRemote;
    if (createRemote == null) {
      throw const MlangeException(
        mlangeStatusUnsupported,
        'Native library does not export mlange_model_create_remote.',
      );
    }
    final personalKeyPointer = personalKey.toNativeUtf8();
    final namePointer = name.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    final progressCallback = _nativeProgressCallback(onProgress);
    try {
      final status = createRemote(
        personalKeyPointer.cast(),
        namePointer.cast(),
        version ?? -1,
        options.mode.nativeValue,
        options.quantType?.index ?? -1,
        options.target?.nativeValue ?? -1,
        options.apType.nativeValue,
        options.cacheHandlingPolicy.nativeValue,
        progressCallback?.nativeFunction ?? nullptr,
        nullptr,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(personalKeyPointer);
      calloc.free(namePointer);
      calloc.free(outHandle);
      progressCallback?.close();
    }
  }

  Future<Pointer<Void>> modelCreateRemoteAsync(
    String personalKey,
    String name, {
    int? version,
    MlangeLoadOptions options = const MlangeLoadOptions(),
    MlangeProgressCallback? onProgress,
  }) async {
    if (_createRemote == null) {
      throw const MlangeException(
        mlangeStatusUnsupported,
        'Native library does not export mlange_model_create_remote.',
      );
    }
    final progressCallback = _nativeProgressCallback(onProgress);
    try {
      final request = _RemoteModelCreateRequest(
        personalKey: personalKey,
        name: name,
        version: version ?? -1,
        mode: options.mode.nativeValue,
        quantType: options.quantType?.index ?? -1,
        target: options.target?.nativeValue ?? -1,
        apType: options.apType.nativeValue,
        cacheHandlingPolicy: options.cacheHandlingPolicy.nativeValue,
        progressCallbackAddress: progressCallback?.nativeFunction.address ?? 0,
      );
      final handleAddress = await Isolate.run(
        () => _modelCreateRemoteInIsolate(request),
      );
      await Future<void>.delayed(Duration.zero);
      return Pointer<Void>.fromAddress(handleAddress);
    } finally {
      progressCallback?.close();
    }
  }

  static int _modelCreateRemoteInIsolate(_RemoteModelCreateRequest request) {
    final bindings = DynamicMlangeBindings();
    return bindings
        ._modelCreateRemoteWithNativeCallbacks(
          request.personalKey,
          request.name,
          version: request.version,
          mode: request.mode,
          quantType: request.quantType,
          target: request.target,
          apType: request.apType,
          cacheHandlingPolicy: request.cacheHandlingPolicy,
          progressCallbackAddress: request.progressCallbackAddress,
        )
        .address;
  }

  Pointer<Void> _modelCreateRemoteWithNativeCallbacks(
    String personalKey,
    String name, {
    required int version,
    required int mode,
    required int quantType,
    required int target,
    required int apType,
    required int cacheHandlingPolicy,
    required int progressCallbackAddress,
  }) {
    final createRemote = _createRemote;
    if (createRemote == null) {
      throw const MlangeException(
        mlangeStatusUnsupported,
        'Native library does not export mlange_model_create_remote.',
      );
    }
    final personalKeyPointer = personalKey.toNativeUtf8();
    final namePointer = name.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    try {
      final status = createRemote(
        personalKeyPointer.cast(),
        namePointer.cast(),
        version,
        mode,
        quantType,
        target,
        apType,
        cacheHandlingPolicy,
        progressCallbackAddress == 0
            ? nullptr
            : Pointer<NativeFunction<_ProgressCallbackNative>>.fromAddress(
                progressCallbackAddress,
              ),
        nullptr,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(personalKeyPointer);
      calloc.free(namePointer);
      calloc.free(outHandle);
    }
  }

  @override
  Pointer<Void> hfModelCreate(
    String repoId, {
    String? userAccessToken,
    String? manifestDir,
    int index = 0,
    CacheHandlingPolicy cacheHandlingPolicy =
        CacheHandlingPolicy.removeOverlapping,
  }) {
    final hfCreate = _hfCreate;
    if (hfCreate == null) {
      throw const MlangeException(
        mlangeStatusUnsupported,
        'Native library does not export mlange_hf_model_create.',
      );
    }
    final repoIdPointer = repoId.toNativeUtf8();
    final tokenPointer = userAccessToken?.toNativeUtf8();
    final manifestDirPointer = manifestDir?.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    try {
      final status = hfCreate(
        repoIdPointer.cast(),
        tokenPointer?.cast() ?? nullptr,
        manifestDirPointer?.cast() ?? nullptr,
        index,
        cacheHandlingPolicy.nativeValue,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(repoIdPointer);
      if (tokenPointer != null) {
        calloc.free(tokenPointer);
      }
      if (manifestDirPointer != null) {
        calloc.free(manifestDirPointer);
      }
      calloc.free(outHandle);
    }
  }

  @override
  void modelRelease(Pointer<Void> handle) {
    if (handle == nullptr) {
      return;
    }
    _release(handle);
  }

  @override
  void modelRun(Pointer<Void> handle) {
    final status = _run(handle);
    if (status != mlangeStatusOk) {
      throw MlangeException(status, _errorFor(handle));
    }
  }

  @override
  int modelInputCount(Pointer<Void> handle) {
    return _countOrThrow(handle, _inputCount);
  }

  @override
  int modelOutputCount(Pointer<Void> handle) {
    return _countOrThrow(handle, _outputCount);
  }

  @override
  Tensor modelInputAt(Pointer<Void> handle, int index) {
    return _tensorOrThrow(handle, index, _inputAt);
  }

  @override
  Tensor modelOutputAt(Pointer<Void> handle, int index) {
    return _tensorOrThrow(handle, index, _outputAt);
  }

  @override
  String lastError(Pointer<Void> handle) {
    return _errorFor(handle);
  }

  @override
  Pointer<Void> llmModelCreate(
    String personalKey,
    String name, {
    int? version,
    MlangeLLMLoadOptions options = const MlangeLLMLoadOptions(),
    MlangeProgressCallback? onProgress,
  }) {
    final llmCreate = _llmCreate;
    if (llmCreate == null) {
      throw const MlangeException(
        mlangeStatusUnsupported,
        'Native library does not export mlange_llm_model_create.',
      );
    }
    final personalKeyPointer = personalKey.toNativeUtf8();
    final namePointer = name.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    final progressCallback = _nativeProgressCallback(onProgress);
    try {
      final status = llmCreate(
        personalKeyPointer.cast(),
        namePointer.cast(),
        version ?? -1,
        options.mode.nativeValue,
        options.apType?.nativeValue ?? APType.na.nativeValue,
        options.quantType?.nativeValue ?? -1,
        options.cacheHandlingPolicy.nativeValue,
        options.contextSize,
        options.kvCacheCleanupPolicy.nativeValue,
        progressCallback?.nativeFunction ?? nullptr,
        nullptr,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _llmErrorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(personalKeyPointer);
      calloc.free(namePointer);
      calloc.free(outHandle);
      progressCallback?.close();
    }
  }

  Future<Pointer<Void>> llmModelCreateAsync(
    String personalKey,
    String name, {
    int? version,
    MlangeLLMLoadOptions options = const MlangeLLMLoadOptions(),
    MlangeProgressCallback? onProgress,
  }) async {
    if (_llmCreate == null) {
      throw _missingLlmSymbol('mlange_llm_model_create');
    }
    final progressCallback = _nativeProgressCallback(onProgress);
    try {
      final request = _LlmModelCreateRequest(
        personalKey: personalKey,
        name: name,
        version: version ?? -1,
        mode: options.mode.nativeValue,
        apType: options.apType?.nativeValue ?? APType.na.nativeValue,
        quantType: options.quantType?.nativeValue ?? -1,
        cacheHandlingPolicy: options.cacheHandlingPolicy.nativeValue,
        contextSize: options.contextSize,
        kvCacheCleanupPolicy: options.kvCacheCleanupPolicy.nativeValue,
        progressCallbackAddress: progressCallback?.nativeFunction.address ?? 0,
      );
      final handleAddress = await Isolate.run(
        () => _llmModelCreateInIsolate(request),
      );
      await Future<void>.delayed(Duration.zero);
      return Pointer<Void>.fromAddress(handleAddress);
    } finally {
      progressCallback?.close();
    }
  }

  static int _llmModelCreateInIsolate(_LlmModelCreateRequest request) {
    final bindings = DynamicMlangeBindings();
    return bindings
        ._llmModelCreateWithNativeCallbacks(
          request.personalKey,
          request.name,
          version: request.version,
          mode: request.mode,
          apType: request.apType,
          quantType: request.quantType,
          cacheHandlingPolicy: request.cacheHandlingPolicy,
          contextSize: request.contextSize,
          kvCacheCleanupPolicy: request.kvCacheCleanupPolicy,
          progressCallbackAddress: request.progressCallbackAddress,
        )
        .address;
  }

  Pointer<Void> _llmModelCreateWithNativeCallbacks(
    String personalKey,
    String name, {
    required int version,
    required int mode,
    required int apType,
    required int quantType,
    required int cacheHandlingPolicy,
    required int contextSize,
    required int kvCacheCleanupPolicy,
    required int progressCallbackAddress,
  }) {
    final llmCreate = _llmCreate;
    if (llmCreate == null) {
      throw _missingLlmSymbol('mlange_llm_model_create');
    }
    final personalKeyPointer = personalKey.toNativeUtf8();
    final namePointer = name.toNativeUtf8();
    final outHandle = calloc<Pointer<Void>>();
    try {
      final status = llmCreate(
        personalKeyPointer.cast(),
        namePointer.cast(),
        version,
        mode,
        apType,
        quantType,
        cacheHandlingPolicy,
        contextSize,
        kvCacheCleanupPolicy,
        progressCallbackAddress == 0
            ? nullptr
            : Pointer<NativeFunction<_ProgressCallbackNative>>.fromAddress(
                progressCallbackAddress,
              ),
        nullptr,
        outHandle,
      );
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _llmErrorFor(outHandle.value));
      }
      return outHandle.value;
    } finally {
      calloc.free(personalKeyPointer);
      calloc.free(namePointer);
      calloc.free(outHandle);
    }
  }

  @override
  void llmModelRelease(Pointer<Void> handle) {
    if (handle == nullptr) {
      return;
    }
    final release = _llmRelease;
    if (release == null) {
      throw _missingLlmSymbol('mlange_llm_model_release');
    }
    release(handle);
  }

  @override
  int llmModelRun(Pointer<Void> handle, String prompt) {
    final run = _llmRun;
    if (run == null) {
      throw _missingLlmSymbol('mlange_llm_model_run');
    }
    final promptPointer = prompt.toNativeUtf8();
    final promptTokens = calloc<Int32>();
    try {
      final status = run(handle, promptPointer.cast(), promptTokens);
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _llmErrorFor(handle));
      }
      return promptTokens.value;
    } finally {
      calloc.free(promptPointer);
      calloc.free(promptTokens);
    }
  }

  @override
  MlangeNextToken llmModelWaitForNextToken(Pointer<Void> handle) {
    final wait = _llmWaitForNextToken;
    if (wait == null) {
      throw _missingLlmSymbol('mlange_llm_model_wait_for_next_token');
    }
    final token = calloc<Pointer<Char>>();
    final generatedTokens = calloc<Int32>();
    final code = calloc<Int32>();
    try {
      final status = wait(handle, token, generatedTokens, code);
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _llmErrorFor(handle));
      }
      return MlangeNextToken(
        token: token.value == nullptr
            ? ''
            : token.value.cast<Utf8>().toDartString(),
        generatedTokens: generatedTokens.value,
        code: code.value,
      );
    } finally {
      calloc.free(token);
      calloc.free(generatedTokens);
      calloc.free(code);
    }
  }

  @override
  void llmModelCleanUp(Pointer<Void> handle) {
    final cleanUp = _llmCleanUp;
    if (cleanUp == null) {
      throw _missingLlmSymbol('mlange_llm_model_cleanup');
    }
    final status = cleanUp(handle);
    if (status != mlangeStatusOk) {
      throw MlangeException(status, _llmErrorFor(handle));
    }
  }

  @override
  void llmModelForceDeinit(Pointer<Void> handle) {
    final forceDeinit = _llmForceDeinit;
    if (forceDeinit == null) {
      throw _missingLlmSymbol('mlange_llm_model_force_deinit');
    }
    forceDeinit(handle);
  }

  @override
  String llmLastError(Pointer<Void> handle) {
    return _llmErrorFor(handle);
  }

  int _countOrThrow(Pointer<Void> handle, _ModelCountDart countFunction) {
    final outCount = calloc<Int32>();
    try {
      final status = countFunction(handle, outCount);
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(handle));
      }
      return outCount.value;
    } finally {
      calloc.free(outCount);
    }
  }

  Tensor _tensorOrThrow(
    Pointer<Void> handle,
    int index,
    _TensorAtDart tensorFunction,
  ) {
    final tensor = calloc<MlangeNativeTensor>();
    try {
      final status = tensorFunction(handle, index, tensor.cast<Void>());
      if (status != mlangeStatusOk) {
        throw MlangeException(status, _errorFor(handle));
      }
      final ref = tensor.ref;
      if (ref.data == nullptr && ref.byteLength > 0) {
        throw const MlangeException(
          -1,
          'Native tensor pointer is null for a non-empty tensor.',
        );
      }
      return Tensor.view(
        data: ref.byteLength == 0
            ? Uint8List(0)
            : ref.data.asTypedList(ref.byteLength),
        dataType: DataType.fromNativeValue(ref.dtype),
        shape: ref.shape.asTypedList(ref.rank).toList(growable: false),
      );
    } finally {
      calloc.free(tensor);
    }
  }

  String _errorFor(Pointer<Void> handle) {
    final pointer = _lastError(handle);
    if (pointer == nullptr) {
      return 'Unknown native error.';
    }
    return pointer.cast<Utf8>().toDartString();
  }

  String _llmErrorFor(Pointer<Void> handle) {
    final lastError = _llmLastError;
    if (lastError == null) {
      return 'Unknown native LLM error.';
    }
    final pointer = lastError(handle);
    if (pointer == nullptr) {
      return 'Unknown native LLM error.';
    }
    return pointer.cast<Utf8>().toDartString();
  }

  MlangeException _missingLlmSymbol(String symbol) {
    return MlangeException(
      mlangeStatusUnsupported,
      'Native library does not export $symbol.',
    );
  }

  F? _lookupOptional<F extends Function>(F Function() lookup) {
    try {
      return lookup();
    } on ArgumentError {
      return null;
    }
  }

  NativeCallable<_ProgressCallbackNative>? _nativeProgressCallback(
    MlangeProgressCallback? callback,
  ) {
    if (callback == null) {
      return null;
    }
    return NativeCallable<_ProgressCallbackNative>.listener(callback);
  }
}

DynamicLibrary _openDefaultLibrary() {
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libzetic_mlange_flutter_bridge.so');
  }
  throw UnsupportedError('zetic_mlange FFI supports iOS and Android only.');
}

final class _RemoteModelCreateRequest {
  const _RemoteModelCreateRequest({
    required this.personalKey,
    required this.name,
    required this.version,
    required this.mode,
    required this.quantType,
    required this.target,
    required this.apType,
    required this.cacheHandlingPolicy,
    required this.progressCallbackAddress,
  });

  final String personalKey;
  final String name;
  final int version;
  final int mode;
  final int quantType;
  final int target;
  final int apType;
  final int cacheHandlingPolicy;
  final int progressCallbackAddress;
}

final class _LlmModelCreateRequest {
  const _LlmModelCreateRequest({
    required this.personalKey,
    required this.name,
    required this.version,
    required this.mode,
    required this.apType,
    required this.quantType,
    required this.cacheHandlingPolicy,
    required this.contextSize,
    required this.kvCacheCleanupPolicy,
    required this.progressCallbackAddress,
  });

  final String personalKey;
  final String name;
  final int version;
  final int mode;
  final int apType;
  final int quantType;
  final int cacheHandlingPolicy;
  final int contextSize;
  final int kvCacheCleanupPolicy;
  final int progressCallbackAddress;
}

typedef _ModelCreateNative =
    Int32 Function(
      Pointer<Char>,
      Int32,
      Int32,
      Int32,
      Int32,
      Pointer<Pointer<Void>>,
    );
typedef _ModelCreateDart =
    int Function(Pointer<Char>, int, int, int, int, Pointer<Pointer<Void>>);
typedef _ModelCreateRemoteNative =
    Int32 Function(
      Pointer<Char>,
      Pointer<Char>,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Pointer<NativeFunction<_ProgressCallbackNative>>,
      Pointer<NativeFunction<_StatusCallbackNative>>,
      Pointer<Pointer<Void>>,
    );
typedef _ModelCreateRemoteDart =
    int Function(
      Pointer<Char>,
      Pointer<Char>,
      int,
      int,
      int,
      int,
      int,
      int,
      Pointer<NativeFunction<_ProgressCallbackNative>>,
      Pointer<NativeFunction<_StatusCallbackNative>>,
      Pointer<Pointer<Void>>,
    );
typedef _HfModelCreateNative =
    Int32 Function(
      Pointer<Char>,
      Pointer<Char>,
      Pointer<Char>,
      Int32,
      Int32,
      Pointer<Pointer<Void>>,
    );
typedef _HfModelCreateDart =
    int Function(
      Pointer<Char>,
      Pointer<Char>,
      Pointer<Char>,
      int,
      int,
      Pointer<Pointer<Void>>,
    );
typedef _ModelReleaseNative = Void Function(Pointer<Void>);
typedef _ModelReleaseDart = void Function(Pointer<Void>);
typedef _ModelRunNative = Int32 Function(Pointer<Void>);
typedef _ModelRunDart = int Function(Pointer<Void>);
typedef _ModelCountNative = Int32 Function(Pointer<Void>, Pointer<Int32>);
typedef _ModelCountDart = int Function(Pointer<Void>, Pointer<Int32>);
typedef _TensorAtNative = Int32 Function(Pointer<Void>, Int32, Pointer<Void>);
typedef _TensorAtDart = int Function(Pointer<Void>, int, Pointer<Void>);
typedef _LastErrorNative = Pointer<Char> Function(Pointer<Void>);
typedef _LastErrorDart = Pointer<Char> Function(Pointer<Void>);
typedef _LLMCreateNative =
    Int32 Function(
      Pointer<Char>,
      Pointer<Char>,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Pointer<NativeFunction<_ProgressCallbackNative>>,
      Pointer<NativeFunction<_StatusCallbackNative>>,
      Pointer<Pointer<Void>>,
    );
typedef _LLMCreateDart =
    int Function(
      Pointer<Char>,
      Pointer<Char>,
      int,
      int,
      int,
      int,
      int,
      int,
      int,
      Pointer<NativeFunction<_ProgressCallbackNative>>,
      Pointer<NativeFunction<_StatusCallbackNative>>,
      Pointer<Pointer<Void>>,
    );
typedef _ProgressCallbackNative = Void Function(Float);
typedef _StatusCallbackNative = Void Function(Int32);
typedef _LLMRunNative =
    Int32 Function(Pointer<Void>, Pointer<Char>, Pointer<Int32>);
typedef _LLMRunDart =
    int Function(Pointer<Void>, Pointer<Char>, Pointer<Int32>);
typedef _LLMWaitForNextTokenNative =
    Int32 Function(
      Pointer<Void>,
      Pointer<Pointer<Char>>,
      Pointer<Int32>,
      Pointer<Int32>,
    );
typedef _LLMWaitForNextTokenDart =
    int Function(
      Pointer<Void>,
      Pointer<Pointer<Char>>,
      Pointer<Int32>,
      Pointer<Int32>,
    );
