import 'package:map_history/map_history.dart';
import 'package:test/test.dart';

void main() {
  group('MapHistory', () {
    test('basic', () {
      var m = MapHistory<int, String>();
      expect(m.isEmpty, isTrue);
      expect(m.isNotEmpty, isFalse);
      expect(m.length, equals(0));
      expect(m.version, equals(0));
      expect(m.keys, equals([]));
      expect(m.values, equals([]));

      expect(m.containsKey(101), isFalse);
      expect(m.containsValue('a'), isFalse);

      m[101] = 'a';

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('a'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(1));
      expect(m.version, equals(1));
      expect(m.keys, equals([101]));
      expect(m.values, equals(['a']));

      m[102] = 'b';

      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('b'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(2));
      expect(m.version, equals(2));
      expect(m.keys, equals([101, 102]));
      expect(m.values, equals(['a', 'b']));

      m[101] = 'A';

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('a'), isFalse);
      expect(m.containsValue('A'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(2));
      expect(m.version, equals(3));
      expect(m.keys, equals([101, 102]));
      expect(m.values, equals(['A', 'b']));

      expect(m.containsKey(103), isFalse);
      expect(m.containsValue('c'), isFalse);

      m[103] = 'c';

      expect(m.containsKey(103), isTrue);
      expect(m.containsValue('c'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(3));
      expect(m.version, equals(4));
      expect(m.keys, equals([101, 102, 103]));
      expect(m.values, equals(['A', 'b', 'c']));

      var ver = m.version;

      m[102] = 'B';

      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('B'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(3));
      expect(m.version, equals(5));
      expect(m.keys, equals([101, 102, 103]));
      expect(m.values, equals(['A', 'B', 'c']));

      expect(m.rollback(ver)?.equals(MapEntry(103, 'c')), isTrue);

      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('b'), isTrue);
      expect(m.containsValue('B'), isFalse);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(3));
      expect(m.version, equals(4));
      expect(m.keys, equals([101, 102, 103]));
      expect(m.values, equals(['A', 'b', 'c']));

      m[104] = 'd';

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(4));
      expect(m.version, equals(5));
      expect(m.keys, equals([101, 102, 103, 104]));
      expect(m.values, equals(['A', 'b', 'c', 'd']));

      ver = m.version;

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('A'), isTrue);

      m.remove(101);

      expect(m.containsKey(101), isFalse);
      expect(m.containsValue('A'), isFalse);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(3));
      expect(m.version, equals(6));
      expect(m.keys, equals([102, 103, 104]));
      expect(m.values, equals(['b', 'c', 'd']));

      expect(m.rollback(ver)?.equals(MapEntry(104, 'd')), isTrue);

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('A'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(4));
      expect(m.version, equals(5));
      expect(m.keys, equals([101, 102, 103, 104]));
      expect(m.values, equals(['A', 'b', 'c', 'd']));

      m.putIfAbsent(103, () => 'C');

      expect(m.length, equals(4));
      expect(m.version, equals(5));
      expect(m.keys, equals([101, 102, 103, 104]));
      expect(m.values, equals(['A', 'b', 'c', 'd']));

      ver = m.version;

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('A'), isTrue);
      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('b'), isTrue);

      m.clear();

      expect(m.containsKey(101), isFalse);
      expect(m.containsValue('A'), isFalse);
      expect(m.containsKey(102), isFalse);
      expect(m.containsValue('b'), isFalse);

      expect(m.isEmpty, isTrue);
      expect(m.isNotEmpty, isFalse);
      expect(m.length, equals(0));
      expect(m.version, equals(9));
      expect(m.keys, equals([]));
      expect(m.values, equals([]));

      expect(m.rollback(ver)?.equals(MapEntry(104, 'd')), isTrue);

      expect(m.containsKey(101), isTrue);
      expect(m.containsValue('A'), isTrue);
      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('b'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(4));
      expect(m.version, equals(5));
      expect(m.keys, equals([101, 102, 103, 104]));
      expect(m.values, equals(['A', 'b', 'c', 'd']));

      expect(m.map((key, value) => MapEntry(key * 10, '$value.')),
          equals({1010: 'A.', 1020: 'b.', 1030: 'c.', 1040: 'd.'}));

      expect(m.toString(), equals('{101: A, 102: b, 103: c, 104: d}'));

      m.putIfAbsent(105, () => 'e');

      expect(m.length, equals(5));
      expect(m.version, equals(6));
      expect(m.keys, equals([101, 102, 103, 104, 105]));
      expect(m.values, equals(['A', 'b', 'c', 'd', 'e']));

      expect(m, equals({101: 'A', 102: 'b', 103: 'c', 104: 'd', 105: 'e'}));

      m.addAll({106: 'f', 107: 'g'});

      expect(
          m,
          equals({
            101: 'A',
            102: 'b',
            103: 'c',
            104: 'd',
            105: 'e',
            106: 'f',
            107: 'g'
          }));

      ver = m.version;
      var lastTime = m.lastTime;

      m.removeWhere((key, value) => key >= 105);

      expect(m, equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(m.findOperationEntryByVersion(ver)?.equals(MapEntry(107, 'g')),
          isTrue);

      expect(m.findOperationVersionByTime(lastTime), equals(ver));
      expect(m.findOperationVersionByTime(lastTime.add(Duration(seconds: 1))),
          equals(m.version));

      expect(
          m.findOperationVersionByTime(
              lastTime.subtract(Duration(minutes: 10))),
          equals(0));

      m.rollback(m.version);

      expect(m, equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(m.toMap(), equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));
      expect(m.toMap(), isNot(isA<MapHistory<int, String>>()));

      expect(MapHistory.of(m.toMap()),
          equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));
      expect(MapHistory<int, String>.from(m.toMap()),
          equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));
      expect(MapHistory<int, String>.from(Map<Object, Object>.from(m)),
          equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(MapHistory<int, String>.from(m.cast<Object, Object>()),
          equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(
          () => m.cast<String, String>().toString(), throwsA(isA<TypeError>()));

      expect(MapHistory.fromEntries(m.toMap().entries),
          equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(MapHistory.fromIterables([1001, 1002], ['A', 'B']),
          equals({1001: 'A', 1002: 'B'}));

      m.rollback(ver);

      expect(
          m,
          equals({
            101: 'A',
            102: 'b',
            103: 'c',
            104: 'd',
            105: 'e',
            106: 'f',
            107: 'g'
          }));

      m.updateAll((key, value) => key >= 105 ? value.toUpperCase() : value);

      var str = StringBuffer();
      m.forEach((key, value) => str.write('$key:$value '));
      expect(
          str.toString(), equals('101:A 102:b 103:c 104:d 105:E 106:F 107:G '));

      m.update(102, (value) => '$value.');

      m.update(108, (value) => '$value.', ifAbsent: () => 'x');

      expect(
          m,
          equals({
            101: 'A',
            102: 'b.',
            103: 'c',
            104: 'd',
            105: 'E',
            106: 'F',
            107: 'G',
            108: 'x'
          }));

      m.purgeAll();

      expect(m.isEmpty, isTrue);
      expect(m.isNotEmpty, isFalse);
      expect(m.length, equals(0));
      expect(m.version, equals(0));
      expect(m.keys, equals([]));
      expect(m.values, equals([]));
      expect(m, equals({}));
    });
  });
}

extension _MapEntryExntesion<K, V> on MapEntry<K, V> {
  bool equals(MapEntry<K, V> other) => key == other.key && value == other.value;
}
