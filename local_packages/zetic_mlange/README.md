# ZeticMLange Flutter

Flutter SDK for running ZeticMLange on-device AI models on Android and iOS.

ZeticMLange loads models deployed from the ZETIC dashboard and runs inference through
the native Android and iOS runtimes. The Flutter package exposes Dart APIs for
general model inference, supported Hugging Face models, and LLM token generation.

## Features

- Run ZeticMLange models on-device from Flutter.
- Load models by personal key, model name, and optional version.
- Run tensor-based inference with Dart `Tensor` values.
- Stream generated tokens from on-device LLM models.
- Select model mode, quantization, target, accelerator type, and cache policy.
- Use the same Dart API surface on Android and iOS.

## Platform support

| Platform | Minimum |
| --- | --- |
| Android | API 24+ |
| iOS | iOS 16.6+ |
| Dart | 3.11.5+ |
| Flutter | 3.35.0+ |

## Installation

Add the package to your Flutter app:

```yaml
dependencies:
  zetic_mlange: ^1.8.1
```

Then install dependencies:

```sh
flutter pub get
```

This package requires the ZeticMLange native runtime to be available in the
host app. Follow the Flutter setup guide for Android and iOS integration:

- [Flutter setup](https://docs.zetic.ai/platform-integration/flutter/setup)
- [Flutter basic inference](https://docs.zetic.ai/platform-integration/flutter/basic-inference)
- [Flutter API reference](https://docs.zetic.ai/api-reference/flutter/ZeticMLangeModel)

## Basic inference

```dart
import 'dart:typed_data';

import 'package:zetic_mlange/zetic_mlange.dart';

Future<Float32List> runModel({
  required String personalKey,
  required String modelName,
  required Float32List inputValues,
}) async {
  final model = await ZeticMLangeModel.create(
    personalKey: personalKey,
    name: modelName,
  );

  try {
    final input = Tensor.float32List(
      inputValues,
      shape: const [1, 3, 224, 224],
    );

    final outputs = model.run([input]);
    return outputs.first.asFloat32List();
  } finally {
    model.close();
  }
}
```

## LLM generation

```dart
import 'package:zetic_mlange/zetic_mlange.dart';

Future<void> generateText({
  required String personalKey,
  required String modelName,
}) async {
  final llm = await ZeticMLangeLLMModel.create(
    personalKey: personalKey,
    name: modelName,
    initOption: const LLMInitOption(nCtx: 4096),
  );

  try {
    llm.run('Explain on-device AI in one paragraph.');

    while (true) {
      final next = llm.waitForNextToken();
      if (next.isFinished) {
        break;
      }
      print(next.token);
    }

    llm.cleanUp();
  } finally {
    llm.close();
  }
}
```

## Hugging Face models

Supported Hugging Face models can be loaded with `ZeticMLangeHFModel`:

```dart
final model = await ZeticMLangeHFModel.create(
  'owner/repository',
  userAccessToken: userAccessToken,
);

try {
  final outputs = model.run(inputs);
} finally {
  model.close();
}
```

See the [Hugging Face model guide](https://docs.zetic.ai/model-preparation/hugging-face-models)
for supported formats and deployment requirements.

## Public API

The package exports:

- `ZeticMLangeModel`
- `ZeticMLangeHFModel`
- `ZeticMLangeLLMModel`
- `Tensor`
- `DataType`, `Target`, `APType`, `ModelMode`, `QuantType`
- `LLMModelMode`, `LLMTarget`, `LLMQuantType`, `LLMInitOption`
- `LLMKVCacheCleanupPolicy`, `CacheHandlingPolicy`
- `MlangeException`

## Documentation

Full documentation is available at [docs.zetic.ai](https://docs.zetic.ai).

Useful starting points:

- [Quick start](https://docs.zetic.ai/quick-start)
- [Flutter setup](https://docs.zetic.ai/platform-integration/flutter/setup)
- [Flutter API reference](https://docs.zetic.ai/api-reference/flutter/ZeticMLangeModel)
- [Troubleshooting](https://docs.zetic.ai/troubleshooting/common-errors)

## License

Apache-2.0. See [LICENSE](LICENSE).
