import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:multicast_dns/multicast_dns.dart';

typedef MDnsClientFactory = MDnsClient Function();

class MdnsResolver {
  static const MethodChannel _defaultChannel =
      MethodChannel('com.example.flutter_todo/multicast_lock');

  final Duration timeout;
  final MDnsClientFactory _clientFactory;
  final Future<void> Function()? _acquireLockOverride;
  final Future<void> Function()? _releaseLockOverride;
  final Map<String, String> _cache = {};

  MdnsResolver({
    this.timeout = const Duration(seconds: 3),
    MDnsClientFactory? clientFactory,
    Future<void> Function()? acquireLock,
    Future<void> Function()? releaseLock,
  })  : _clientFactory = clientFactory ?? (() => MDnsClient()),
        _acquireLockOverride = acquireLock,
        _releaseLockOverride = releaseLock;

  /// Returns an unmodifiable view of the current IP cache.
  Map<String, String> get cache => Map.unmodifiable(_cache);

  /// Evicts a specific host from the in-memory cache.
  void invalidate(String host) {
    _cache.remove(host);
  }

  /// Clears all cached hosts.
  void clearCache() {
    _cache.clear();
  }

  Future<void> _acquireLock() async {
    final override = _acquireLockOverride;
    if (override != null) {
      await override();
      return;
    }
    if (Platform.isAndroid) {
      try {
        await _defaultChannel.invokeMethod('acquire');
      } catch (_) {
        // Silently ignore if channel is unavailable in test environments
      }
    }
  }

  Future<void> _releaseLock() async {
    final override = _releaseLockOverride;
    if (override != null) {
      await override();
      return;
    }
    if (Platform.isAndroid) {
      try {
        await _defaultChannel.invokeMethod('release');
      } catch (_) {
        // Silently ignore if channel is unavailable in test environments
      }
    }
  }

  /// Resolves [host] to an IPv4 address.
  ///
  /// If [host] does not end in `.local`, it is returned unchanged.
  /// If [host] was previously resolved and is in the cache, the cached IP is returned.
  /// Otherwise, an mDNS lookup is performed within [timeout].
  Future<String> resolveHost(String host) async {
    if (!host.endsWith('.local')) {
      return host;
    }

    if (_cache.containsKey(host)) {
      return _cache[host]!;
    }

    await _acquireLock();
    final client = _clientFactory();
    try {
      await client.start();
      final stream = client.lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(host),
        timeout: timeout,
      );

      final completer = Completer<String>();
      late StreamSubscription<IPAddressResourceRecord> subscription;

      final timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription.cancel();
          completer.completeError(
            TimeoutException(
              'Appliance "$host" was not found on the local Wi-Fi network within ${timeout.inSeconds} seconds.',
            ),
          );
        }
      });

      subscription = stream.listen(
        (record) {
          if (!completer.isCompleted) {
            timer.cancel();
            subscription.cancel();
            final ip = record.address.address;
            _cache[host] = ip;
            completer.complete(ip);
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            timer.cancel();
            completer.completeError(e);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            timer.cancel();
            completer.completeError(
              TimeoutException(
                'Appliance "$host" was not found on the local network (mDNS query finished without responses).',
              ),
            );
          }
        },
        cancelOnError: true,
      );

      return await completer.future;
    } finally {
      client.stop();
      await _releaseLock();
    }
  }
}
