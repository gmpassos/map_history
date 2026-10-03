import 'dart:math';

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
      expect(m.baseVersion, equals(0));
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
      expect(m.baseVersion, equals(1));
      expect(m.keys, equals([101]));
      expect(m.values, equals(['a']));

      m[102] = 'b';

      expect(m.containsKey(102), isTrue);
      expect(m.containsValue('b'), isTrue);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(2));
      expect(m.version, equals(2));
      expect(m.baseVersion, equals(1));
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
      expect(m.baseVersion, equals(1));
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

      ver = m.version;
      var lastTime = m.lastTime;

      expect(m.length, equals(5));
      expect(m.version, equals(6));
      expect(m.keys, equals([101, 102, 103, 104, 105]));
      expect(m.values, equals(['A', 'b', 'c', 'd', 'e']));

      expect(m, equals({101: 'A', 102: 'b', 103: 'c', 104: 'd', 105: 'e'}));

      expect(m.findOperationVersionByTime(lastTime), equals(ver));
      expect(m.findOperationVersionByTime(lastTime.add(Duration(seconds: 1))),
          equals(m.version));

      expect(
          m.findOperationVersionByTime(
              lastTime.subtract(Duration(minutes: 10))),
          equals(0));

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

      m.removeWhere((key, value) => key >= 105);

      expect(m, equals({101: 'A', 102: 'b', 103: 'c', 104: 'd'}));

      expect(m.findOperationEntryByVersion(ver)?.equals(MapEntry(107, 'g')),
          isTrue);

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

      expect(() => m.update(108, (value) => '$value.'), throwsArgumentError);

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

      ver = m.version;

      expect(m.consolidate(-1), equals(1));
      expect(m.baseVersion, equals(1));

      expect(m.consolidate(ver), equals(9));
      expect(m.baseVersion, equals(9));

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

      expect(m.consolidate(ver + 1), equals(ver));
      expect(m.baseVersion, equals(ver));

      m.purgeAll();

      expect(m.isEmpty, isTrue);
      expect(m.isNotEmpty, isFalse);
      expect(m.length, equals(0));
      expect(m.version, equals(17));
      expect(m.keys, equals([]));
      expect(m.values, equals([]));
      expect(m, equals({}));
    });

    test('rollback + consolidate', () {
      var m = MapHistory<int, String>.fromIterables([1, 3, 2], ['a', 'c', 'b']);

      expect(m.isEmpty, isFalse);
      expect(m.isNotEmpty, isTrue);
      expect(m.length, equals(3));
      expect(m.version, equals(3));
      expect(m.baseVersion, equals(1));
      expect(m, equals({1: 'a', 2: 'b', 3: 'c'}));

      expect(m.consolidate(m.version), equals(1));
      expect(m, equals({1: 'a', 2: 'b', 3: 'c'}));

      m[2] = 'b.';
      expect(m, equals({1: 'a', 2: 'b.', 3: 'c'}));

      m[2] = 'B';
      expect(m, equals({1: 'a', 2: 'B', 3: 'c'}));

      var ver = m.version;

      m.remove(2);
      expect(m, equals({1: 'a', 3: 'c'}));

      expect(m.rollback(m.version + 1), isNull);

      m.rollback(ver);
      expect(m, equals({1: 'a', 2: 'B', 3: 'c'}));

      m.remove(3);
      m[1] = 'A';
      expect(m, equals({1: 'A', 2: 'B'}));

      expect(m.rollback(m.version)?.equals(MapEntry(1, 'A')), isTrue);

      expect(m.consolidate(ver), equals(1));
      expect(m, equals({1: 'A', 2: 'B'}));

      m.rollback(ver);
      expect(m, equals({1: 'a', 2: 'B', 3: 'c'}));

      expect(m.rollback(m.version)?.equals(MapEntry(2, 'B')), isTrue);

      expect(m.rollback(m.baseVersion - 1), isNull);
      expect(m.isEmpty, isTrue);
    });

    // `consolidate` only visits the keys changed since they were last
    // consolidated. This checks it against [_ReferenceMapHistory], which
    // visits every key (the original algorithm), over random operations.
    test('consolidate/rollback equivalent to a full scan (randomized)', () {
      for (var seed = 1; seed <= 30; ++seed) {
        var random = Random(seed);
        var m = MapHistory<int, String>();
        var ref = _ReferenceMapHistory();

        for (var step = 0; step < 1500; ++step) {
          var key = random.nextInt(12);
          var value = 'v$step';
          var op = random.nextInt(100);

          String desc;
          if (op < 35) {
            desc = 'put($key)';
            m[key] = value;
            ref.put(key, value);
          } else if (op < 50) {
            desc = 'remove($key)';
            m.remove(key);
            ref.remove(key);
          } else if (op < 55) {
            desc = 'putIfAbsent($key)';
            m.putIfAbsent(key, () => value);
            ref.putIfAbsent(key, value);
          } else if (op < 60) {
            desc = 'update($key)';
            m.update(key, (v) => '$v.', ifAbsent: () => value);
            ref.update(key, (v) => '$v.', value);
          } else if (op < 62) {
            desc = 'clear';
            m.clear();
            ref.clear();
          } else if (op < 64) {
            desc = 'removeWhere(odd)';
            m.removeWhere((k, v) => k.isOdd);
            ref.removeWhere((k) => k.isOdd);
          } else if (op < 66) {
            desc = 'updateAll';
            m.updateAll((k, v) => '$v!');
            ref.updateAll((v) => '$v!');
          } else if (op < 80) {
            var target = m.baseVersion - 1 + random.nextInt(m.version + 3);
            desc = 'rollback($target)';
            var r1 = m.rollback(target);
            var r2 = ref.rollback(target);
            expect(
              r1 == null ? null : '${r1.key}=${r1.value}',
              equals(r2),
              reason: 'seed: $seed ; step: $step ; $desc',
            );
          } else {
            var target = random.nextInt(m.version + 3) - 1;
            desc = 'consolidate($target)';
            expect(
              m.consolidate(target),
              equals(ref.consolidate(target)),
              reason: 'seed: $seed ; step: $step ; $desc',
            );
          }

          var reason = 'seed: $seed ; step: $step ; $desc';
          expect(m.toMap(), equals(ref.toMap()), reason: reason);
          expect(m.length, equals(ref.length), reason: reason);
          expect(m.version, equals(ref.version), reason: reason);
          expect(m.baseVersion, equals(ref.baseVersion), reason: reason);
        }
      }
    });
  });
}

/// The original [MapHistory] history algorithm, visiting every key on each
/// [consolidate] and [rollback]: the reference for the randomized test.
class _ReferenceMapHistory {
  final Map<int, List<_RefEntry>> _entries = {};
  int _zeroVersion = 0;
  int _version = 0;

  int get version => _version;

  int get baseVersion => _zeroVersion == _version ? _version : _zeroVersion + 1;

  Map<int, String> toMap() => {
        for (var e in _entries.entries)
          if (e.value.isNotEmpty && !e.value.last.deleted)
            e.key: e.value.last.value!,
      };

  int get length => toMap().length;

  bool _isLive(List<_RefEntry>? l) =>
      l != null && l.isNotEmpty && !l.last.deleted;

  void put(int key, String value) =>
      (_entries[key] ??= []).add(_RefEntry(key, ++_version, value));

  void putIfAbsent(int key, String value) {
    var l = _entries[key] ??= [];
    if (!_isLive(l)) l.add(_RefEntry(key, ++_version, value));
  }

  void update(int key, String Function(String) f, String ifAbsent) {
    var l = _entries[key] ??= [];
    var value = _isLive(l) ? f(l.last.value!) : ifAbsent;
    l.add(_RefEntry(key, ++_version, value));
  }

  void remove(int key) {
    var l = _entries[key];
    if (_isLive(l)) l!.add(_RefEntry(key, ++_version, null));
  }

  void clear() => removeWhere((k) => true);

  void removeWhere(bool Function(int key) test) {
    for (var e in _entries.entries) {
      if (_isLive(e.value) && test(e.key)) {
        e.value.add(_RefEntry(e.key, ++_version, null));
      }
    }
  }

  void updateAll(String Function(String) f) {
    for (var e in _entries.entries) {
      if (_isLive(e.value)) {
        e.value.add(_RefEntry(e.key, ++_version, f(e.value.last.value!)));
      }
    }
  }

  void _clearAll() {
    _entries.clear();
    _version = _zeroVersion;
  }

  String? _describe(_RefEntry? e) => e == null || e.deleted ? null : '$e';

  String? rollback(int targetVersion) {
    if (targetVersion <= _zeroVersion) {
      _clearAll();
      return null;
    } else if (targetVersion == _version) {
      for (var l in _entries.values) {
        for (var e in l) {
          if (e.version == targetVersion) return _describe(e);
        }
      }
      return null;
    } else if (targetVersion > _version) {
      return null;
    }

    _RefEntry? target;
    for (var l in _entries.values) {
      l.removeWhere((e) {
        if (e.version <= targetVersion) {
          if (target == null || target!.version < e.version) target = e;
          return false;
        }
        return true;
      });
      if (l.length == 1 && l.first.deleted) l.clear();
    }
    _entries.removeWhere((k, l) => l.isEmpty);

    var found = target;
    if (found == null) {
      _clearAll();
      return null;
    }
    _version = found.version;
    return _describe(found);
  }

  int consolidate(int targetBaseVersion) {
    if (targetBaseVersion <= _zeroVersion) {
      return baseVersion;
    } else if (targetBaseVersion > _version) {
      var ver = _version;
      _clearAll();
      _zeroVersion = _version = ver;
      return baseVersion;
    }

    var minimalVersion = _version;
    for (var l in _entries.values) {
      while (l.length > 2 && l.first.version < targetBaseVersion) {
        l.removeAt(0);
      }
      if (l.length == 2 && l.last.version < targetBaseVersion) {
        l.removeAt(0);
      }
      if (l.length == 1 && l.first.deleted) {
        l.clear();
      } else if (l.first.version < minimalVersion) {
        minimalVersion = l.first.version;
      }
    }
    _entries.removeWhere((k, l) => l.isEmpty);

    _zeroVersion = minimalVersion - 1;
    return baseVersion;
  }
}

class _RefEntry {
  final int key;
  final int version;
  final String? value;

  _RefEntry(this.key, this.version, this.value);

  bool get deleted => value == null;

  @override
  String toString() => '$key=$value';
}

extension _MapEntryExntesion<K, V> on MapEntry<K, V> {
  bool equals(MapEntry<K, V> other) => key == other.key && value == other.value;
}
