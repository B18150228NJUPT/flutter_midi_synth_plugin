import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FlutterMidiSynth {
  static const MethodChannel _channel = MethodChannel('flutter_midi_synth');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> prepare({
    required ByteData? sf2,
    String name = 'instrument.sf2',
  }) async {
    if (sf2 == null) return Future.value(null);
    if (kIsWeb) return _channel.invokeMethod('prepare_midi');
    File? _file = await writeToFile(sf2, name: name);
    if (_file == null) return null;
    return _channel.invokeMethod('prepare_midi', {'path': _file.path});
  }

  @override
  Future<String?> stopMidiNote({required int midi}) async {
    return _channel.invokeMethod('stop_midi_note', {'note': midi});
  }

  @override
  Future<String?> playMidiNote({required int midi}) async {
    return _channel.invokeMethod('play_midi_note', {'note': midi});
  }

  Future<File?> writeToFile(ByteData data,
      {String name = "instrument.sf2"}) async {
    if (kIsWeb) return null;
    final buffer = data.buffer;
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$name";
    return File(path)
        .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
