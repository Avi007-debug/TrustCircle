enum ModelMode {
  runAuto(0),
  runFp32(1),
  runQuantized(2),
  runSpeed(3),
  runAccuracy(4);

  const ModelMode(this.nativeValue);

  final int nativeValue;
}

enum QuantType { fp32, fp16, int }

enum Target {
  torch(0),
  tfliteFp32(1),
  ort(2),
  ortNnapi(3),
  qnn(4),
  qnnQuant(5),
  coreMl(6),
  coreMlFp32(7),
  neuropilot(8),
  neuropilotQuant(9),
  exynos(10),
  exynosQuant(11),
  kirin(12),
  kirinQuant(13),
  ggml(14),
  ggmlQuant(15),
  tfliteFp16(16),
  qnnFp16(17),
  coreMlQuant(18),
  tfliteQuant(19),
  mtb(20),
  mtbQuant(21),
  litertFp32(22),
  litertFp16(23),
  litertQuant(24),
  numModels(25),
  numSlots(64),
  fail(65);

  const Target(this.nativeValue);

  final int nativeValue;

  static Target fromNativeValue(int value) {
    for (final target in values) {
      if (target.nativeValue == value) {
        return target;
      }
    }
    return Target.fail;
  }

  static Target fromName(String name) {
    final normalized = name
        .replaceFirst('ZETIC_MLANGE_TARGET_', '')
        .replaceAll('_', '')
        .toLowerCase();
    for (final target in values) {
      if (target.name.toLowerCase() == normalized) {
        return target;
      }
    }
    return Target.fail;
  }
}

enum APType {
  cpu(0),
  gpu(1),
  npu(2),
  na(63);

  const APType(this.nativeValue);

  final int nativeValue;
}

enum DataType {
  unknown(0, 1),
  float32(1, 4),
  float64(2, 8),
  float16(3, 2),
  bfloat16(4, 2),
  uint8(5, 1),
  uint16(6, 2),
  uint32(7, 4),
  uint64(8, 8),
  int8(9, 1),
  int16(10, 2),
  int32(11, 4),
  int64(12, 8),
  boolean(13, 1),
  qint8(14, 1),
  qint16(15, 2),
  qint32(16, 4),
  qint4(17, 1);

  const DataType(this.nativeValue, this.bytesPerElement);

  final int nativeValue;
  final int bytesPerElement;

  static DataType fromNativeValue(int value) {
    for (final dtype in values) {
      if (dtype.nativeValue == value) {
        return dtype;
      }
    }
    return DataType.unknown;
  }

  static DataType fromName(String name) {
    final normalized = name.toLowerCase();
    if (normalized == 'bool') {
      return DataType.boolean;
    }
    for (final dtype in values) {
      if (dtype.name == normalized) {
        return dtype;
      }
    }
    return DataType.unknown;
  }

  static String toName(DataType dataType) {
    return dataType == DataType.boolean ? 'bool' : dataType.name;
  }
}

final class MlangeException implements Exception {
  const MlangeException(this.code, this.message, [this.nativeStack]);

  final int code;
  final String message;
  final String? nativeStack;

  @override
  String toString() {
    final stack = nativeStack;
    if (stack == null || stack.isEmpty) {
      return 'MlangeException($code): $message';
    }
    return 'MlangeException($code): $message\n$stack';
  }
}

final class MlangeLoadOptions {
  const MlangeLoadOptions({
    this.mode = ModelMode.runAuto,
    this.quantType,
    this.target,
    this.apType = APType.na,
    this.cacheHandlingPolicy = CacheHandlingPolicy.removeOverlapping,
  });

  final ModelMode mode;
  final QuantType? quantType;
  final Target? target;
  final APType apType;
  final CacheHandlingPolicy cacheHandlingPolicy;
}

enum CacheHandlingPolicy {
  removeOverlapping(0),
  keepExisting(1);

  const CacheHandlingPolicy(this.nativeValue);

  final int nativeValue;
}

enum LLMModelMode {
  runAuto(0),
  runSpeed(1),
  runAccuracy(2);

  const LLMModelMode(this.nativeValue);

  final int nativeValue;
}

enum LLMTarget {
  llamaCpp(0),
  litertLm(1),
  mllm(2);

  const LLMTarget(this.nativeValue);

  final int nativeValue;

  static LLMTarget fromNativeValue(int value) {
    for (final target in values) {
      if (target.nativeValue == value) {
        return target;
      }
    }
    return LLMTarget.llamaCpp;
  }

  static LLMTarget fromName(String name) {
    final normalized = name
        .replaceFirst('ZETIC_MLANGE_LLM_TARGET_', '')
        .replaceAll('_', '')
        .toLowerCase();
    for (final target in values) {
      if (target.name.toLowerCase() == normalized) {
        return target;
      }
    }
    return LLMTarget.llamaCpp;
  }
}

enum LLMQuantType {
  ggufQuantOrg(0),
  ggufQuantF16(1),
  ggufQuantBf16(2),
  ggufQuantQ80(3),
  ggufQuantQ4KM(4),
  ggufQuantQ3KM(5),
  ggufQuantQ2K(6),
  ggufQuantQ6K(7),
  ggufQuantNumTypes(8);

  const LLMQuantType(this.nativeValue);

  final int nativeValue;
}

final class LLMInitOption {
  const LLMInitOption({
    this.kvCacheCleanupPolicy = LLMKVCacheCleanupPolicy.cleanUpOnFull,
    this.nCtx = 2048,
  });

  final LLMKVCacheCleanupPolicy kvCacheCleanupPolicy;
  final int nCtx;
}

enum LLMKVCacheCleanupPolicy {
  cleanUpOnFull(0),
  doNotCleanUp(1);

  const LLMKVCacheCleanupPolicy(this.nativeValue);

  final int nativeValue;
}

final class MlangeLLMLoadOptions {
  const MlangeLLMLoadOptions({
    this.mode = LLMModelMode.runAuto,
    this.apType,
    this.quantType,
    this.cacheHandlingPolicy = CacheHandlingPolicy.removeOverlapping,
    this.kvCacheCleanupPolicy = LLMKVCacheCleanupPolicy.cleanUpOnFull,
    this.contextSize = 2048,
  });

  final LLMModelMode mode;
  final APType? apType;
  final LLMQuantType? quantType;
  final CacheHandlingPolicy cacheHandlingPolicy;
  final LLMKVCacheCleanupPolicy kvCacheCleanupPolicy;
  final int contextSize;
}

typedef ZeticMLangeCacheHandlingPolicy = CacheHandlingPolicy;

typedef ModelCacheHandlingPolicy = CacheHandlingPolicy;

typedef MlangeProgressCallback = void Function(double progress);

typedef LLMRunResult = MlangeLLMRunResult;

typedef LLMNextTokenResult = MlangeNextToken;

final class MlangeLLMRunResult {
  const MlangeLLMRunResult({required this.status, required this.promptTokens});

  final int status;
  final int promptTokens;
}

final class MlangeNextToken {
  const MlangeNextToken({
    required this.token,
    required this.generatedTokens,
    required this.code,
    this.timeUs = 0,
    this.isFirst = false,
    this.isFinal = false,
  });

  final String token;
  final int generatedTokens;
  final int code;
  final int timeUs;
  final bool isFirst;
  final bool isFinal;

  int get status => code;

  bool get isFinished => isFinal || token.isEmpty;
}
