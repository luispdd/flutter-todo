import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_todo/services/mdns_resolver.dart';
import 'package:flutter_todo/services/screen_api_service.dart';
import 'package:multicast_dns/multicast_dns.dart';

class FakeMDnsClient implements MDnsClient {
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
  }) async {}

  @override
  void stop() {}

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
  group('ScreenApiService Tests', () {
    test('fetchTasks resolves screen.local to IP and returns list of tasks on 200 OK', () async {
      var mdnsLookupCount = 0;
      final resolver = MdnsResolver(
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) {
            mdnsLookupCount++;
            return Stream.value(
              IPAddressResourceRecord(
                'screen.local',
                1000,
                address: InternetAddress('192.168.1.188'),
              ),
            );
          },
        ),
      );

      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals('http://192.168.1.188/tasks'));
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'text': 'Task 1',
              'done': false,
              'created_at': '2026-10-21 12:00',
            },
            {
              'id': 2,
              'text': 'Task 2',
              'done': true,
              'created_at': '2026-10-21 12:05',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = ScreenApiService(
        client: mockClient,
        mdnsResolver: resolver,
      );
      final tasks = await service.fetchTasks();

      expect(tasks.length, equals(2));
      expect(tasks[0].id, equals(1));
      expect(tasks[0].text, equals('Task 1'));
      expect(tasks[0].done, isFalse);
      expect(tasks[1].done, isTrue);
      expect(mdnsLookupCount, equals(1));

      // Second call reuses cached resolved IP
      await service.fetchTasks();
      expect(mdnsLookupCount, equals(1));
    });

    test('deleteTask sends DELETE to resolved IP and returns true on 200', () async {
      final resolver = MdnsResolver(
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) => Stream.value(
            IPAddressResourceRecord(
              'screen.local',
              1000,
              address: InternetAddress('192.168.1.188'),
            ),
          ),
        ),
      );

      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.toString(), equals('http://192.168.1.188/tasks/5'));
        return http.Response(jsonEncode({'status': 'deleted'}), 200);
      });

      final service = ScreenApiService(
        client: mockClient,
        mdnsResolver: resolver,
      );
      final result = await service.deleteTask(5);
      expect(result, isTrue);
    });

    test('createTasks posts JSON array to resolved IP and returns created tasks', () async {
      final resolver = MdnsResolver(
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) => Stream.value(
            IPAddressResourceRecord(
              'screen.local',
              1000,
              address: InternetAddress('192.168.1.188'),
            ),
          ),
        ),
      );

      final mockClient = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.toString(), equals('http://192.168.1.188/tasks'));
        final body = jsonDecode(request.body) as List;
        expect(body.length, equals(2));
        expect(body[0]['text'], equals('Buy milk'));

        return http.Response(
          jsonEncode([
            {
              'id': 10,
              'text': 'Buy milk',
              'done': false,
              'created_at': '2026-10-21 12:10',
            },
            {
              'id': 11,
              'text': 'Call Alice',
              'done': false,
              'created_at': '2026-10-21 12:11',
            },
          ]),
          201,
        );
      });

      final service = ScreenApiService(
        client: mockClient,
        mdnsResolver: resolver,
      );
      final result = await service.createTasks(['Buy milk', 'Call Alice']);

      expect(result.length, equals(2));
      expect(result[0].id, equals(10));
    });

    test('Non-.local baseUrl bypasses mDNS resolver', () async {
      var mdnsCalled = false;
      final resolver = MdnsResolver(
        clientFactory: () {
          mdnsCalled = true;
          return FakeMDnsClient();
        },
      );

      final mockClient = MockClient((request) async {
        expect(request.url.toString(), equals('http://192.168.1.50/tasks'));
        return http.Response('[]', 200);
      });

      final service = ScreenApiService(
        baseUrl: 'http://192.168.1.50',
        client: mockClient,
        mdnsResolver: resolver,
      );
      final tasks = await service.fetchTasks();
      expect(tasks, isEmpty);
      expect(mdnsCalled, isFalse);
    });

    test('Network error invalidates cached IP address in resolver', () async {
      final resolver = MdnsResolver(
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) => Stream.value(
            IPAddressResourceRecord(
              'screen.local',
              1000,
              address: InternetAddress('192.168.1.188'),
            ),
          ),
        ),
      );

      final mockClient = MockClient((request) async {
        throw http.ClientException('Connection dropped');
      });

      final service = ScreenApiService(
        client: mockClient,
        mdnsResolver: resolver,
      );

      expect(() => service.fetchTasks(), throwsA(isA<http.ClientException>()));
      // After failure, cache should be invalidated
      expect(resolver.cache.containsKey('screen.local'), isFalse);
    });

    test('Discovery timeout throws descriptive exception', () async {
      final resolver = MdnsResolver(
        timeout: const Duration(milliseconds: 20),
        clientFactory: () => FakeMDnsClient(
          onLookup: (query) => const Stream.empty(),
        ),
      );

      final service = ScreenApiService(
        client: MockClient((_) async => http.Response('', 200)),
        mdnsResolver: resolver,
      );

      expect(
        () => service.fetchTasks(),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
