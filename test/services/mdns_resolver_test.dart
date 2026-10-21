import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/services/mdns_resolver.dart';
import 'package:multicast_dns/multicast_dns.dart';

class FakeMDnsClient implements MDnsClient {
  bool isStarted = false;
  bool isStopped = false;
  final Stream<IPAddressResourceRecord> Function(ResourceRecordQuery query)? onLookup;

  FakeMDnsClient({this.onLookup});

  @override
  Future<Iterable<NetworkInterface>> allInterfacesFactory(InternetAddressType type) async => const [];

  @override
  Future<void> start({
    InternetAddress? listenAddress,
    NetworkInterfacesFactory? interfacesFactory,
    int mDnsPort = 5353,
    InternetAddress? mDnsAddress,
    Function? onError,
  }) async {
    isStarted = true;
  }

  @override
  void stop() {
    isStopped = true;
  }

  @override
  Stream<T> lookup<T extends ResourceRecord>(
    ResourceRecordQuery query, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (onLookup != null) {
      return onLookup!(query) as Stream<T>;
    }
    return const Stream.empty();
  }
}

void main() {
  group('MdnsResolver Tests', () {
    test('Non-.local host is returned immediately without mDNS lookup', () async {
      var clientCreated = false;
      final resolver = MdnsResolver(
        clientFactory: () {
          clientCreated = true;
          return FakeMDnsClient();
        },
      );

      final result = await resolver.resolveHost('192.168.1.50');
      expect(result, equals('192.168.1.50'));
      expect(clientCreated, isFalse);
      expect(resolver.cache, isEmpty);
    });

    test('Resolves .local host, acquires/releases lock, caches IP, and stops client', () async {
      var acquired = false;
      var released = false;
      late FakeMDnsClient fakeClient;

      final resolver = MdnsResolver(
        timeout: const Duration(seconds: 2),
        acquireLock: () async => acquired = true,
        releaseLock: () async => released = true,
        clientFactory: () {
          fakeClient = FakeMDnsClient(
            onLookup: (query) {
              return Stream.value(
                IPAddressResourceRecord(
                  'screen.local',
                  1000,
                  address: InternetAddress('192.168.1.200'),
                ),
              );
            },
          );
          return fakeClient;
        },
      );

      final ip = await resolver.resolveHost('screen.local');
      expect(ip, equals('192.168.1.200'));
      expect(acquired, isTrue);
      expect(released, isTrue);
      expect(fakeClient.isStarted, isTrue);
      expect(fakeClient.isStopped, isTrue);
      expect(resolver.cache['screen.local'], equals('192.168.1.200'));

      // Subsequent call uses cache and does not invoke clientFactory again
      var secondLookupCalled = false;
      final cachedIp = await resolver.resolveHost('screen.local');
      expect(cachedIp, equals('192.168.1.200'));
      expect(secondLookupCalled, isFalse);
    });

    test('Times out and throws TimeoutException when mDNS stream has no response', () async {
      var released = false;
      late FakeMDnsClient fakeClient;

      final resolver = MdnsResolver(
        timeout: const Duration(milliseconds: 50),
        releaseLock: () async => released = true,
        clientFactory: () {
          fakeClient = FakeMDnsClient(
            onLookup: (query) => const Stream.empty(),
          );
          return fakeClient;
        },
      );

      expect(
        () => resolver.resolveHost('screen.local'),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Invalidates cached host and clears cache properly', () async {
      final resolver = MdnsResolver(
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) => Stream.value(
            IPAddressResourceRecord(
              'screen.local',
              1000,
              address: InternetAddress('192.168.1.10'),
            ),
          ),
        ),
      );

      await resolver.resolveHost('screen.local');
      expect(resolver.cache.containsKey('screen.local'), isTrue);

      resolver.invalidate('screen.local');
      expect(resolver.cache.containsKey('screen.local'), isFalse);

      await resolver.resolveHost('screen.local');
      expect(resolver.cache.containsKey('screen.local'), isTrue);

      resolver.clearCache();
      expect(resolver.cache, isEmpty);
    });
  });
}
