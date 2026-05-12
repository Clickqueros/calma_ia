// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

void initAudio() => _Bowl.instance.init();
void startAudio() => _Bowl.instance.start();
void stopAudio() => _Bowl.instance.fadeOut();
void disposeAudio() => _Bowl.instance.dispose();
void rampGain(double target, double durationSecs) =>
    _Bowl.instance.rampGain(target, durationSecs);

// ── Tibetan Bowl synthesizer ────────────────────────────────────────────────
//
// Creates a warm, resonant bowl tone using layered sine oscillators.
// Frequencies tuned to 432 Hz (healing frequency) + its harmonics.
// Max volume is deliberately very low (0.06) — ambient texture, not foreground.

class _Bowl {
  _Bowl._();
  static final instance = _Bowl._();

  js.JsObject? _ctx;
  js.JsObject? _masterGain;
  final List<js.JsObject> _oscillators = [];
  bool _started = false;

  // [frequency Hz, relative amplitude]
  static const _partials = [
    (432.0,  1.00),   // fundamental — 432 Hz
    (433.4,  0.90),   // micro-detune → gentle beating / warmth
    (864.0,  0.35),   // 2nd harmonic
    (865.8,  0.30),   // detuned 2nd harmonic
    (1296.0, 0.14),   // 3rd harmonic
    (528.0,  0.18),   // Solfeggio harmonic (adds silkiness)
  ];

  void init() {
    if (_ctx != null) return;
    try {
      final ctor = js.context['AudioContext'] ?? js.context['webkitAudioContext'];
      _ctx = js.JsObject(ctor as js.JsFunction);

      _masterGain = _ctx!.callMethod('createGain') as js.JsObject;
      (_masterGain!['gain'] as js.JsObject)['value'] = 0.0;
      _masterGain!.callMethod('connect', [_ctx!['destination']]);

      // Create one oscillator per partial
      for (final partial in _partials) {
        final osc = _ctx!.callMethod('createOscillator') as js.JsObject;
        osc['type'] = 'sine';
        (osc['frequency'] as js.JsObject)['value'] = partial.$1;

        final partialGain = _ctx!.callMethod('createGain') as js.JsObject;
        (partialGain['gain'] as js.JsObject)['value'] = partial.$2;

        osc.callMethod('connect', [partialGain]);
        partialGain.callMethod('connect', [_masterGain]);
        _oscillators.add(osc);
      }
    } catch (_) {}
  }

  void start() {
    if (_started || _ctx == null) return;
    try {
      _ctx!.callMethod('resume');
      for (final osc in _oscillators) {
        osc.callMethod('start', [0]);
      }
      _started = true;
    } catch (_) {}
  }

  void rampGain(double target, double durationSecs) {
    if (_ctx == null || !_started || _masterGain == null) return;
    try {
      // Cap max master gain so the bowl stays delicate
      final capped = target.clamp(0.0, 0.060);
      final now = (_ctx!['currentTime'] as num).toDouble();
      final gain = _masterGain!['gain'] as js.JsObject;
      final current = (gain['value'] as num).toDouble();
      gain.callMethod('cancelScheduledValues', [now]);
      gain.callMethod('setValueAtTime', [current, now]);
      gain.callMethod('linearRampToValueAtTime', [capped, now + durationSecs]);
    } catch (_) {}
  }

  void fadeOut() {
    if (_ctx == null || _masterGain == null) return;
    try {
      final now = (_ctx!['currentTime'] as num).toDouble();
      final gain = _masterGain!['gain'] as js.JsObject;
      final current = (gain['value'] as num).toDouble();
      gain.callMethod('cancelScheduledValues', [now]);
      gain.callMethod('setValueAtTime', [current, now]);
      gain.callMethod('linearRampToValueAtTime', [0.0, now + 2.0]);
    } catch (_) {}
  }

  void dispose() {
    try {
      for (final osc in _oscillators) {
        osc.callMethod('stop', [0]);
      }
      _ctx?.callMethod('close');
    } catch (_) {}
    _oscillators.clear();
    _ctx = null;
    _masterGain = null;
    _started = false;
  }
}
