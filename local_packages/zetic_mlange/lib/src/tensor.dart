import 'dart:math';
import 'dart:typed_data';

import 'types.dart';

final class Tensor {
  Tensor({
    required Uint8List data,
    DataType dataType = DataType.int8,
    List<int>? shape,
  }) : this._(
         data: Uint8List.fromList(data),
         dataType: dataType,
         shape: shape ?? [data.lengthInBytes],
       );

  Tensor.view({
    required Uint8List data,
    DataType dataType = DataType.int8,
    List<int>? shape,
  }) : this._(
         data: data,
         dataType: dataType,
         shape: shape ?? [data.lengthInBytes],
       );

  Tensor._({
    required this.data,
    required this.dataType,
    required List<int> shape,
  }) : shape = List<int>.unmodifiable(shape) {
    final expectedBytes = elementCount * dataType.bytesPerElement;
    if (expectedBytes != data.lengthInBytes) {
      throw MlangeException(
        -1,
        'Shape does not match tensor data size: '
        '$expectedBytes expected, ${data.lengthInBytes} actual.',
      );
    }
  }

  Tensor.bytes(
    List<int> data, {
    DataType dataType = DataType.int8,
    List<int>? shape,
  }) : this(data: Uint8List.fromList(data), dataType: dataType, shape: shape);

  factory Tensor.bytesView(
    Uint8List data, {
    DataType dataType = DataType.int8,
    List<int>? shape,
  }) {
    return Tensor.view(data: data, dataType: dataType, shape: shape);
  }

  factory Tensor.float32List(Float32List data, {List<int>? shape}) {
    return Tensor(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.float32,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.float32View(Float32List data, {List<int>? shape}) {
    return Tensor.view(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.float32,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.float64List(Float64List data, {List<int>? shape}) {
    return Tensor(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.float64,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.float64View(Float64List data, {List<int>? shape}) {
    return Tensor.view(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.float64,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.int32List(Int32List data, {List<int>? shape}) {
    return Tensor(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.int32,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.int32View(Int32List data, {List<int>? shape}) {
    return Tensor.view(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.int32,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.int64List(Int64List data, {List<int>? shape}) {
    return Tensor(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.int64,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.int64View(Int64List data, {List<int>? shape}) {
    return Tensor.view(
      data: Uint8List.view(data.buffer, data.offsetInBytes, data.lengthInBytes),
      dataType: DataType.int64,
      shape: shape ?? [data.length],
    );
  }

  factory Tensor.random(DataType dataType, List<int> shape, {Random? random}) {
    final generator = random ?? Random();
    final byteLength =
        shape.fold<int>(1, (value, dimension) => value * dimension) *
        dataType.bytesPerElement;
    return Tensor(
      data: Uint8List.fromList([
        for (var index = 0; index < byteLength; index++) generator.nextInt(256),
      ]),
      dataType: dataType,
      shape: shape,
    );
  }

  final Uint8List data;
  final DataType dataType;
  final List<int> shape;

  int get byteLength => data.lengthInBytes;

  int get elementCount {
    if (shape.isEmpty) {
      return 0;
    }
    return shape.fold<int>(1, (value, dimension) => value * dimension);
  }

  int count() => data.lengthInBytes ~/ dataType.bytesPerElement;

  int size() => data.lengthInBytes;

  Uint8List asUint8List() => data;

  Float32List asFloat32List() {
    _checkDType(DataType.float32);
    return data.buffer.asFloat32List(
      data.offsetInBytes,
      data.lengthInBytes ~/ DataType.float32.bytesPerElement,
    );
  }

  Float64List asFloat64List() {
    _checkDType(DataType.float64);
    return data.buffer.asFloat64List(
      data.offsetInBytes,
      data.lengthInBytes ~/ DataType.float64.bytesPerElement,
    );
  }

  Int32List asInt32List() {
    _checkDType(DataType.int32);
    return data.buffer.asInt32List(
      data.offsetInBytes,
      data.lengthInBytes ~/ DataType.int32.bytesPerElement,
    );
  }

  Int64List asInt64List() {
    _checkDType(DataType.int64);
    return data.buffer.asInt64List(
      data.offsetInBytes,
      data.lengthInBytes ~/ DataType.int64.bytesPerElement,
    );
  }

  void _checkDType(DataType expected) {
    if (dataType != expected) {
      throw MlangeException(-1, 'Tensor dtype is $dataType, not $expected.');
    }
  }
}
