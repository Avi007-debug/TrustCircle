import 'dart:ffi';
import 'ffi/mlange_abi.dart';
import 'tensor.dart';
import 'types.dart';

final class ZeticMLangeModel {
  ZeticMLangeModel._(this._bindings, this._handle);

  final MlangeBindings _bindings;
  Pointer<Void> _handle;
  List<Tensor> _outputs = const [];

  static Future<ZeticMLangeModel> create({
    required String personalKey,
    required String name,
    int? version,
    ModelMode modelMode = ModelMode.runAuto,
    QuantType? quantType,
    Target? target,
    APType apType = APType.na,
    MlangeProgressCallback? onProgress,
    ZeticMLangeCacheHandlingPolicy cacheHandlingPolicy =
        CacheHandlingPolicy.removeOverlapping,
    MlangeBindings? bindings,
  }) {
    return _createRemote(
      personalKey: personalKey,
      name: name,
      version: version,
      options: MlangeLoadOptions(
        mode: modelMode,
        quantType: quantType,
        target: target,
        apType: apType,
        cacheHandlingPolicy: cacheHandlingPolicy,
      ),
      onProgress: onProgress,
      bindings: bindings,
    );
  }

  static Future<ZeticMLangeModel> _createRemote({
    required String personalKey,
    required String name,
    int? version,
    MlangeLoadOptions options = const MlangeLoadOptions(),
    MlangeProgressCallback? onProgress,
    MlangeBindings? bindings,
  }) async {
    final nativeBindings = bindings ?? DynamicMlangeBindings();
    final handle = nativeBindings is DynamicMlangeBindings
        ? await nativeBindings.modelCreateRemoteAsync(
            personalKey,
            name,
            version: version,
            options: options,
            onProgress: onProgress,
          )
        : nativeBindings.modelCreateRemote(
            personalKey,
            name,
            version: version,
            options: options,
            onProgress: onProgress,
          );
    return ZeticMLangeModel._(nativeBindings, handle);
  }

  bool get isClosed => _handle == nullptr;

  void close() {
    final handle = _requireOpen();
    _bindings.modelRelease(handle);
    _handle = nullptr;
  }

  List<Tensor> run([List<Tensor> inputs = const []]) {
    final handle = _requireOpen();
    if (inputs.isNotEmpty) {
      final inputBuffers = _getInputBuffers();
      if (inputBuffers.length != inputs.length) {
        throw MlangeException(
          -1,
          'Wrong input array size for given Model inference, Model numInput: '
          '(${inputBuffers.length}), Given (${inputs.length})',
        );
      }
      for (var index = 0; index < inputs.length; index++) {
        _copyTensor(inputs[index], inputBuffers[index]);
      }
    }
    _bindings.modelRun(handle);
    _outputs = _getOutputBuffers();
    return _outputs;
  }

  List<Tensor> _getInputBuffers() {
    final handle = _requireOpen();
    final count = _bindings.modelInputCount(handle);
    return [
      for (var index = 0; index < count; index++)
        _bindings.modelInputAt(handle, index),
    ];
  }

  List<Tensor> _getOutputBuffers() {
    final handle = _requireOpen();
    final count = _bindings.modelOutputCount(handle);
    return [
      for (var index = 0; index < count; index++)
        _bindings.modelOutputAt(handle, index),
    ];
  }

  void _copyTensor(Tensor source, Tensor destination) {
    if (source.size() != destination.size()) {
      throw MlangeException(
        -1,
        'Tensor byte length is ${source.size()}, not ${destination.size()} '
        '(input shape=${source.shape}, dtype=${source.dataType}; '
        'buffer shape=${destination.shape}, dtype=${destination.dataType}).',
      );
    }
    destination.data.setAll(0, source.data);
  }

  Pointer<Void> _requireOpen() {
    final handle = _handle;
    if (handle == nullptr) {
      throw const MlangeException(-1, 'ZeticMLangeModel is already closed.');
    }
    return handle;
  }
}
