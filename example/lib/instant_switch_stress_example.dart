///
///  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
///
///  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
///  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
///  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
///  This notice may not be removed from this file.
///

/// Repro harness for Zendesk #134164 — "document sometimes takes more than 40
/// seconds to load when users frequently switch between documents or repeatedly
/// close and reopen documents" (Android, Instant).
///
/// Drives the public [NutrientInstantView] widget through an automated cycle
/// of either
///  * `switch` — mount doc A, then B, then C, then A … (a new document each
///    cycle), or
///  * `reopen` — mount the same document, unmount it completely, remount it.
///
/// For every cycle it measures the wall-clock gap between mounting the widget
/// and the Instant controller becoming ready (the point at which the native
/// `InstantPdfDocument` is available), then prints a machine-parseable line:
///
///     [REPRO] cycle=3 mode=switch doc=switch-doc-b loadedMs=41022
///
/// Pair it with logcat to correlate against the SDK's own sync logging:
///
///     adb logcat -s Nutri.InstAnnotSyncMgr Instant::Sync flutter
///
/// The 40 s+ symptom shows up as `loadedMs` climbing across cycles while
/// `Nutri.InstAnnotSyncMgr` logs `ALREADY_SYNCING`.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutrient_example/utils/jwt_util.dart';
// The Instant document-open signal is read straight off the native fragment.
// 5.6's NutrientInstantView has no onControllerReady / per-view adapter, and
// Nutrient.androidAdapter can only be set once at initialize() time, so
// polling the fragment is the least invasive way to time a mount. This is
// measurement-only — the viewer itself is the public NutrientInstantView,
// exactly what the customer integrates.
// `getPdfFragment` and `PdfFragment.document` live on generated extensions, so
// those have to be shown alongside the types themselves. The show clause also
// keeps the bindings' Android-side `EdgeInsets` / `Size` / `PageLayoutMode` /
// `ThumbnailBarMode` from colliding with the Flutter and platform-interface
// names used below.
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:nutrient_flutter_android/src/bindings/nutrient_android_sdk_bindings.dart'
    show
        FragmentContainerPlatformView,
        FragmentContainerPlatformView$Companion$$Methods,
        InstantPdfDocument$$Methods,
        InstantPdfFragment,
        InstantPdfFragment$$Methods,
        PdfFragment,
        PdfFragment$$Methods,
        PdfUiFragment,
        Context;
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_android/nutrient_flutter_android.dart'
    show AndroidAdapter;
// ignore: depend_on_referenced_packages
import 'package:nutrient_flutter_platform_interface/nutrient_flutter_platform_interface.dart'
    as platform show Nutrient;
// Hide the main package's AndroidAdapter re-export (a web-compat stub) — the
// adapter must extend the real one from nutrient_flutter_android.
import 'package:nutrient_flutter/nutrient_flutter.dart' hide AndroidAdapter;

/// Workaround for the Instant stale-long-poll leak (ZD#134164):
/// a platform adapter, public API only, that prevents the Instant
/// listen-for-changes long-poll from starting and stops listening on the
/// cached document at teardown. Registering the adapter does not interact
/// with SDK licensing.
///
/// [enabled] gates the behaviour so a single build can compare baseline vs
/// workaround from the UI toggle.
class InstantSyncLifecycleAdapter extends AndroidAdapter {
  /// Toggled from the harness UI.
  static bool enabled = true;

  PdfFragment? _fragment;

  @override
  Future<void> onFragmentAttached(
    PdfUiFragment fragment,
    Context context,
  ) async {
    // Nothing to do at attach; the document is resolved at detach time.
  }

  @override
  Future<void> onPdfFragmentReady(PdfFragment pdfFragment) async {
    _fragment = pdfFragment;
    if (!enabled) return;
    // Prevent the listen-for-changes long-poll from ever starting. Timing
    // matters: this hook fires before the Instant document finishes
    // downloading. Stopping the poll only at dispose is NOT enough — an
    // in-flight long-poll holds its connection-pool slot until the server
    // hold expires (~47-60 s measured), so rapid switching still starves
    // the pool.
    try {
      pdfFragment
          .as(InstantPdfFragment.type)
          .listenToServerChangesWhenVisible = false;
      debugPrint('[REPRO][workaround] disabled listen-when-visible');
    } catch (e) {
      debugPrint('[REPRO][workaround] listen-when-visible failed: $e');
    }
  }

  /// Manually pulls/pushes annotations for the currently mounted view —
  /// the on-demand replacement for the disabled real-time listener.
  /// Fire-and-forget: InstantPdfFragment.syncAnnotations() is null-safe;
  /// errors surface through InstantDocumentListener callbacks.
  void syncNow() {
    final fragment = _fragment;
    if (fragment == null) {
      debugPrint('[REPRO][manual-sync] no fragment mounted');
      return;
    }
    try {
      fragment.as(InstantPdfFragment.type).syncAnnotations();
      debugPrint('[REPRO][manual-sync] requested');
    } catch (e) {
      debugPrint('[REPRO][manual-sync] failed: $e');
    }
  }

  @override
  Future<void> onFragmentDetached() async {
    final fragment = _fragment;
    _fragment = null;
    if (fragment == null) return;
    if (!enabled) return;
    try {
      // Belt-and-braces: also stop listening on the cached document.
      final document = fragment.as(InstantPdfFragment.type).document$1;
      if (document != null) {
        document.setListeningToServerChanges(false);
        document.release();
      }
    } catch (e) {
      debugPrint('[REPRO][workaround] detach cleanup failed: $e');
    }
  }
}

/// The shared adapter instance — also used for [InstantSyncLifecycleAdapter.syncNow].
final InstantSyncLifecycleAdapter instantSyncAdapter =
    InstantSyncLifecycleAdapter();

/// Installs the adapter into the global slot. Guarded so hot-restart or
/// repeated example entry doesn't throw StateError. Note: this does not
/// affect license initialization, which happens separately through
/// Nutrient.initialize in the main package.
void _ensureWorkaroundAdapterInstalled() {
  // ignore: deprecated_member_use
  if (platform.Nutrient.androidAdapter is InstantSyncLifecycleAdapter) return;
  try {
    platform.Nutrient.initialize(androidAdapter: instantSyncAdapter);
  } on StateError {
    debugPrint('[REPRO][workaround] platform.Nutrient already initialized');
  }
}

/// 10.0.2.2 is the Android emulator's loopback to the host. Point this at a
/// Document Engine that has the `fresh-doc-01`..`fresh-doc-30` and
/// `clean-doc-a` documents uploaded, e.g.:
///
///     for i in $(seq -w 1 30); do
///       curl -X POST http://localhost:5001/api/documents \
///         -H "Authorization: Token token=<API_AUTH_TOKEN>" \
///         -F "document_id=fresh-doc-$i" -F "file=@document.pdf"
///     done
///
/// The bundled JwtUtil signs Instant JWTs with the demo keypair, so the
/// server's JWT_PUBLIC_KEY must be the matching demo public key.
String get _defaultServerUrl => defaultTargetPlatform == TargetPlatform.android
    ? 'http://10.0.2.2:5001'
    : 'http://localhost:5001';

/// Documents pre-uploaded to the local Document Engine. See the repro notes.
///
/// These must be built from a PDF with no `pspdfkit/media` annotations. Core
/// reports an unrepresentable annotation type as `Database corrupted`, which
/// runs `didDetectCorruption()` -> `ServerDocumentImpl::invalidate()` and kills
/// the cached layer for the rest of the process — a real bug, but a different
/// one from the sync-backoff path this harness is meant to measure.
///
/// Switch mode walks the `fresh-doc-NN` pool (30 uploaded), starting from a
/// random offset, so every cycle opens a DISTINCT document — matching the
/// customer's workflow where each approval is a document the device has never
/// downloaded. Reopen mode keeps using [_reopenDocumentId].
const int _freshDocPoolSize = 30;
const String _reopenDocumentId = 'clean-doc-a';

String _freshDocId(int index) =>
    'fresh-doc-${((index) % _freshDocPoolSize + 1).toString().padLeft(2, '0')}';

/// What the automated runner does between measurements.
enum StressMode {
  /// Mount a *different* document each cycle (customer's "switch between
  /// documents" path).
  switchDocuments,

  /// Mount the *same* document every cycle, fully unmounting in between
  /// (customer's "close and reopen documents" path).
  reopenSameDocument,
}

/// One measured mount.
class _CycleResult {
  _CycleResult({
    required this.cycle,
    required this.documentId,
    required this.loadedMs,
    required this.timedOut,
  });

  final int cycle;
  final String documentId;
  final int loadedMs;
  final bool timedOut;
}

class InstantSwitchStressExample extends StatefulWidget {
  const InstantSwitchStressExample({super.key});

  @override
  State<InstantSwitchStressExample> createState() =>
      _InstantSwitchStressExampleState();
}

class _InstantSwitchStressExampleState
    extends State<InstantSwitchStressExample> {
  static const Duration _dwell = Duration(milliseconds: 1500);
  static const Duration _gapBetweenMounts = Duration(milliseconds: 250);

  /// Give up on a cycle after this long. Deliberately longer than the 60 s
  /// `MAX_LONG_POLL_DELAY_MS` backoff cap in `AnnotationSyncCoordinator` so a
  /// fully saturated backoff is still recorded rather than truncated.
  static const Duration _loadTimeout = Duration(seconds: 90);

  StressMode _mode = StressMode.switchDocuments;

  /// Random per-run offset into the fresh-doc pool so re-runs don't hit
  /// documents downloaded by a previous run.
  int _poolOffset = DateTime.now().millisecondsSinceEpoch % _freshDocPoolSize;
  int _totalCycles = 12;

  bool _running = false;
  bool _viewMounted = false;
  int _cycle = 0;
  String _documentId = _reopenDocumentId;
  String _jwt = '';

  /// Bumped for every mount so the widget (and its platform view) is fully
  /// recreated rather than updated in place.
  int _viewKey = 0;

  final List<_CycleResult> _results = <_CycleResult>[];

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _ensureWorkaroundAdapterInstalled();
    }
  }

  /// Completed by [NutrientInstantViewAndroid.onControllerReady] for the
  /// current cycle.
  Completer<void>? _loaded;
  Stopwatch? _stopwatch;

  @override
  void dispose() {
    _running = false;
    super.dispose();
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() {
      _running = true;
      _results.clear();
      _cycle = 0;
    });

    debugPrint('[REPRO] run start mode=${_mode.name} cycles=$_totalCycles '
        'server=$_defaultServerUrl');

    for (var i = 1; i <= _totalCycles && _running && mounted; i++) {
      final documentId = _mode == StressMode.switchDocuments
          ? _freshDocId(_poolOffset + i - 1)
          : _reopenDocumentId;

      // Fully unmount first so the platform view is disposed — this is the
      // teardown path that leaves the cached InstantPdfDocument's sync state
      // behind.
      if (_viewMounted) {
        setState(() => _viewMounted = false);
        await Future<void>.delayed(_gapBetweenMounts);
        if (!_running || !mounted) break;
      }

      final loaded = Completer<void>();
      final stopwatch = Stopwatch()..start();
      setState(() {
        _cycle = i;
        _documentId = documentId;
        _jwt = JwtUtil.generateInstantToken(documentId: documentId);
        _loaded = loaded;
        _stopwatch = stopwatch;
        _viewKey++;
        _viewMounted = true;
      });

      debugPrint(
          '[REPRO] cycle=$i mode=${_mode.name} doc=$documentId mounting');

      var timedOut = false;
      try {
        await loaded.future.timeout(_loadTimeout);
      } on TimeoutException {
        timedOut = true;
      }
      stopwatch.stop();

      final result = _CycleResult(
        cycle: i,
        documentId: documentId,
        loadedMs: stopwatch.elapsedMilliseconds,
        timedOut: timedOut,
      );
      debugPrint('[REPRO] cycle=$i mode=${_mode.name} doc=$documentId '
          'loadedMs=${result.loadedMs}${timedOut ? ' TIMEOUT' : ''}');

      if (!mounted) break;
      setState(() => _results.add(result));

      // Let the viewer settle the way a real user would before moving on.
      await Future<void>.delayed(_dwell);
    }

    _poolOffset = (_poolOffset + _totalCycles) % _freshDocPoolSize;
    debugPrint('[REPRO] run end — ${_summary()}');
    if (mounted) setState(() => _running = false);
  }

  String _summary() {
    if (_results.isEmpty) return 'no results';
    final values = _results.map((r) => r.loadedMs).toList()..sort();
    final worst = values.last;
    final median = values[values.length ~/ 2];
    return 'cycles=${_results.length} medianMs=$median worstMs=$worst '
        'timeouts=${_results.where((r) => r.timedOut).length}';
  }

  /// Polls the native side until the Instant document is actually open.
  ///
  /// `getPdfFragment` returns non-null as soon as the fragment is attached —
  /// which happens long before Instant has a document — so the document itself
  /// is the signal that matters here.
  Future<void> _awaitDocumentOpen(int viewId, Completer<void> loaded) async {
    final companion = FragmentContainerPlatformView.Companion;
    try {
      while (!loaded.isCompleted && _running && mounted) {
        final fragment = companion.getPdfFragment(viewId);
        final document = fragment?.document;
        if (document != null) {
          if (!loaded.isCompleted) {
            debugPrint('[REPRO] cycle=$_cycle documentOpen viewId=$viewId '
                'elapsedMs=${_stopwatch?.elapsedMilliseconds}');
            loaded.complete();
            if (InstantSyncLifecycleAdapter.enabled) {
              // Demonstrate the manual-sync path that replaces the disabled
              // real-time listener.
              instantSyncAdapter.syncNow();
            }
          }
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      companion.release();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return Scaffold(
        appBar: AppBar(title: const Text('Instant Switch Stress')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This repro harness targets the Android Instant view '
              '(Zendesk #134164).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Switch Stress'),
        bottom: _running
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: Column(
        children: [
          _Controls(
            mode: _mode,
            totalCycles: _totalCycles,
            running: _running,
            onModeChanged: (mode) => setState(() => _mode = mode),
            onCyclesChanged: (cycles) => setState(() => _totalCycles = cycles),
            onRun: _run,
            onStop: () => setState(() => _running = false),
          ),
          if (defaultTargetPlatform == TargetPlatform.android)
            SwitchListTile(
              dense: true,
              title: const Text('Workaround: stop stale Instant sync'),
              value: InstantSyncLifecycleAdapter.enabled,
              onChanged: _running
                  ? null
                  : (value) => setState(
                      () => InstantSyncLifecycleAdapter.enabled = value),
            ),
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Text(
              _viewMounted
                  ? 'cycle $_cycle · $_documentId · ${_summary()}'
                  : _summary(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _ResultStrip(results: _results),
          Expanded(
            child: _viewMounted
                ? NutrientInstantView(
                    key: ValueKey<int>(_viewKey),
                    serverUrl: _defaultServerUrl,
                    jwt: _jwt,
                    configuration: const NutrientViewConfiguration(
                      pageLayoutMode: PageLayoutMode.single,
                      thumbnailBarMode: ThumbnailBarMode.floating,
                      enableAnnotationEditing: true,
                    ),
                    onViewCreated: (handle) {
                      final loaded = _loaded;
                      if (loaded != null && !loaded.isCompleted) {
                        unawaited(_awaitDocumentOpen(handle.viewId, loaded));
                      }
                    },
                  )
                : const Center(
                    child: Text('— no document mounted —',
                        style: TextStyle(color: Colors.grey)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.mode,
    required this.totalCycles,
    required this.running,
    required this.onModeChanged,
    required this.onCyclesChanged,
    required this.onRun,
    required this.onStop,
  });

  final StressMode mode;
  final int totalCycles;
  final bool running;
  final ValueChanged<StressMode> onModeChanged;
  final ValueChanged<int> onCyclesChanged;
  final VoidCallback onRun;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<StressMode>(
            segments: const <ButtonSegment<StressMode>>[
              ButtonSegment<StressMode>(
                value: StressMode.switchDocuments,
                label: Text('Switch docs'),
              ),
              ButtonSegment<StressMode>(
                value: StressMode.reopenSameDocument,
                label: Text('Close/reopen'),
              ),
            ],
            selected: <StressMode>{mode},
            onSelectionChanged:
                running ? null : (selection) => onModeChanged(selection.first),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Cycles'),
              Expanded(
                child: Slider(
                  value: totalCycles.toDouble(),
                  min: 2,
                  max: 30,
                  divisions: 28,
                  label: '$totalCycles',
                  onChanged: running
                      ? null
                      : (value) => onCyclesChanged(value.round()),
                ),
              ),
              SizedBox(width: 28, child: Text('$totalCycles')),
              const SizedBox(width: 8),
              running
                  ? OutlinedButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    )
                  : ElevatedButton.icon(
                      onPressed: onRun,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultStrip extends StatelessWidget {
  const _ResultStrip({required this.results});

  final List<_CycleResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final result = results[index];
          // Anything past a couple of seconds is already off-baseline for a
          // local Document Engine.
          final slow = result.loadedMs > 5000;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: result.timedOut
                  ? Colors.red.shade100
                  : slow
                      ? Colors.orange.shade100
                      : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${result.cycle} ${result.documentId}',
                    style: const TextStyle(fontSize: 10)),
                Text(
                  result.timedOut
                      ? 'TIMEOUT'
                      : '${(result.loadedMs / 1000).toStringAsFixed(2)} s',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
