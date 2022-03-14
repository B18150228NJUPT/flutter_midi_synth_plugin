package com.example.flutter_midi_synth;

import android.content.Context;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.IOException;

import cn.sherlock.com.sun.media.sound.SF2Soundbank;
import cn.sherlock.com.sun.media.sound.SoftSynthesizer;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import jp.kshoji.javax.sound.midi.InvalidMidiDataException;
import jp.kshoji.javax.sound.midi.MidiUnavailableException;
import jp.kshoji.javax.sound.midi.Receiver;
import jp.kshoji.javax.sound.midi.ShortMessage;

/** FlutterMidiSynthPlugin */
public class FlutterMidiSynthPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private SoftSynthesizer synth;
  private Receiver recv;
  private MethodChannel methodChannel;
  private Context applicationContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_midi_synth");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }else if(call.method.equals("prepare_midi")) {
      try {
        String _path = call.argument("path");
        File _file = new File(_path);
        SF2Soundbank sf = new SF2Soundbank(_file);
        synth = new SoftSynthesizer();
        synth.open();
        synth.loadAllInstruments(sf);
        synth.getChannels()[0].programChange(0);
        synth.getChannels()[1].programChange(1);
        recv = synth.getReceiver();
      } catch (IOException e) {
        e.printStackTrace();
      } catch (MidiUnavailableException e) {
        e.printStackTrace();
      }
    } else if (call.method.equals("play_midi_note")) {
      int _note = call.argument("note");
      try {
        ShortMessage msg = new ShortMessage();
        msg.setMessage(ShortMessage.NOTE_ON, 0, _note, 127);
        recv.send(msg, -1);
      } catch (InvalidMidiDataException e) {
        e.printStackTrace();
      }
    } else if (call.method.equals("stop_midi_note")) {
      int _note = call.argument("note");
      try {
        ShortMessage msg = new ShortMessage();
        msg.setMessage(ShortMessage.NOTE_OFF, 0, _note, 127);
        recv.send(msg, -1);
      } catch (InvalidMidiDataException e) {
        e.printStackTrace();
      }
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
