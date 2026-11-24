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

      // The base is the consolidated version: the history before it is gone
      // (it used to be the minimal first version, 9, which allowed a
      // rollback to a state no longer known).
      expect(m.consolidate(ver), equals(ver));
      expect(m.baseVersion, equals(ver));

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

      // After the current version: all the history, but the entries are
      // kept (they used to be cleared).
      expect(m.consolidate(ver + 1), equals(ver));
      expect(m.baseVersion, equals(ver));
      expect(m.length, equals(8));
      expect(m[108], equals('x'));
      // Rolling back to the current version changes nothing:
      expect(m.rollback(ver)?.equals(MapEntry(108, 'x')), isTrue);
      expect(m.length, equals(8));

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

      expect(m.consolidate(m.version), equals(3));
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

      expect(m.consolidate(ver), equals(ver));
      expect(m, equals({1: 'A', 2: 'B'}));

      m.rollback(ver);
      expect(m, equals({1: 'a', 2: 'B', 3: 'c'}));

      expect(m.rollback(m.version)?.equals(MapEntry(2, 'B')), isTrue);

      expect(m.rollback(m.baseVersion - 1), isNull);
      expect(m.isEmpty, isTrue);
    });

    // Random operations, rollbacks, consolidations and reverts, checked
    // against [_FullHistoryModel], which never trims its history: so it
    // checks the true state, not a copy of an algorithm.
    test('randomized: rollback, consolidate and revertVersions vs. a model',
        () {
      for (var seed = 1; seed <= 40; ++seed) {
        _randomizedRun(seed, steps: 1500, keysCount: 12);
      }
      // Few keys: more operations per key, more conflicts.
      for (var seed = 101; seed <= 120; ++seed) {
        _randomizedRun(seed, steps: 1500, keysCount: 3);
      }
    });
  });

  group('MapHistory.consolidate', () {
    test('keeps the entry in effect at the target version', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['x'] = 0; // v2
      m['x'] = 0; // v3
      m['x'] = 0; // v4
      m['x'] = 0; // v5
      m['x'] = 0; // v6
      m['x'] = 0; // v7
      m['a'] = 8; // v8
      m['a'] = 9; // v9

      // `a` had 3 entries (v1, v8, v9): v1 is the one in effect at v6, so
      // it's kept (it used to be removed, as the first of more than 2).
      expect(m.consolidate(6), equals(6));
      expect(m, equals({'a': 9, 'x': 0}));

      expect(m.rollback(6)?.key, equals('x'));
      expect(m, equals({'a': 1, 'x': 0}));
    });

    test('baseVersion is not before the target version', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['a'] = 2; // v2
      m['b'] = 1; // v3
      m['b'] = 2; // v4
      m['c'] = 1; // v5

      // `c`'s first entry (v5) is after the target: the base is the target.
      expect(m.consolidate(4), equals(4));
      expect(m.baseVersion, equals(4));

      // `a` at v2 and `b` at v4 are known: a rollback to 4 is exact.
      m.rollback(4);
      expect(m, equals({'a': 2, 'b': 2}));

      // Before the base: the history is gone, the map is cleared.
      m.rollback(3);
      expect(m, isEmpty);
    });

    test('after the current version: keeps the entries', () {
      var m = MapHistory<String, int>();
      m['a'] = 1;
      m['a'] = 2;
      m['b'] = 1;
      m.remove('b');
      m['c'] = 3;

      expect(m.consolidate(m.version + 10), equals(m.version));
      expect(m, equals({'a': 2, 'c': 3}));
      expect(m.length, equals(2));
      expect(m.revertibleVersion, equals(m.version + 1));

      // Nothing before the current version is revertible, and the current
      // version is a no-op rollback:
      expect(() => m.revertVersions([m.version]), throwsStateError);
      m.rollback(m.version);
      expect(m, equals({'a': 2, 'c': 3}));

      // New operations work on top:
      m['a'] = 3;
      expect(m.revertVersions([m.version]), equals(1));
      expect(m, equals({'a': 2, 'c': 3}));
    });
  });

  group('MapHistory.revertVersions', () {
    test('reverts only the given versions', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['a'] = 2; // v2: writer A
      m['b'] = 9; // v3: writer B
      var version = m.version;

      expect(m.revertVersions([2]), equals(1));
      expect(m, equals({'a': 1, 'b': 9}));
      // The version doesn't change (never used again):
      expect(m.version, equals(version));

      m['c'] = 1;
      expect(m.version, equals(version + 1));
    });

    test('a later write by another writer is kept (no lost update)', () {
      var m = MapHistory<String, int>();
      m['k'] = 0; // v1
      m['k'] = 1; // v2: writer A
      m['k'] = 2; // v3: writer B (commits)

      // A aborts: B's value stays (a rollback to v1 would lose it).
      expect(m.revertVersions([2]), equals(1));
      expect(m, equals({'k': 2}));
    });

    test('a write after another writer\'s: back to that writer\'s value', () {
      var m = MapHistory<String, int>();
      m['k'] = 0; // v1
      m['k'] = 1; // v2: writer B
      m['k'] = 2; // v3: writer A

      expect(m.revertVersions([3]), equals(1));
      expect(m, equals({'k': 1}));
    });

    test('an insert reverted: the key is gone', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2: inserted by the reverted writer
      expect(m.length, equals(2));

      expect(m.revertVersions([2]), equals(1));
      expect(m, equals({'a': 1}));
      expect(m.length, equals(1));
      expect(m.containsKey('b'), isFalse);
      expect(m.keys, equals(['a']));
    });

    test('a delete reverted: the key is back', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2
      m.remove('b'); // v3: by the reverted writer
      expect(m.length, equals(1));

      expect(m.revertVersions([3]), equals(1));
      expect(m, equals({'a': 1, 'b': 2}));
      expect(m.length, equals(2));
    });

    test('an insert then delete reverted: no trace of the key', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2
      m.remove('b'); // v3

      expect(m.revertVersions([2, 3]), equals(2));
      expect(m, equals({'a': 1}));
      expect(m.length, equals(1));

      // A delete alone reverted from a deleted-then-reinserted key:
      m['c'] = 1; // v4
      m.remove('c'); // v5
      m['c'] = 2; // v6
      expect(m.revertVersions([5]), equals(1));
      expect(m, equals({'a': 1, 'c': 2}));
    });

    test('several writes of one writer, interleaved with another', () {
      var m = MapHistory<String, int>();
      m['k'] = 0; // v1
      var a = <int>[];
      var b = <int>[];

      m['k'] = 10; // A
      a.add(m.version);
      m['j'] = 20; // B
      b.add(m.version);
      m['k'] = 11; // A
      a.add(m.version);
      m['k'] = 21; // B
      b.add(m.version);
      m.remove('j'); // A
      a.add(m.version);

      expect(m, equals({'k': 21}));

      // A aborts: B's writes stay, A's delete of `j` is undone.
      expect(m.revertVersions(a), equals(3));
      expect(m, equals({'k': 21, 'j': 20}));

      // Then B aborts too: back to before both.
      expect(m.revertVersions(b), equals(2));
      expect(m, equals({'k': 0}));
    });

    test('keys: only those searched', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2
      m['a'] = 3; // v3

      // v3 is a write of `a`: searching only `b` finds nothing.
      expect(m.revertVersions([3], keys: ['b']), equals(0));
      expect(m, equals({'a': 3, 'b': 2}));

      // Unknown keys and duplicates are fine:
      expect(m.revertVersions([3], keys: ['a', 'zz', 'a']), equals(1));
      expect(m, equals({'a': 1, 'b': 2}));
    });

    test('versions not in the history are skipped', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['a'] = 2; // v2

      expect(m.revertVersions([]), equals(0));
      expect(m.revertVersions([2]), equals(1));
      // Already reverted:
      expect(m.revertVersions([2]), equals(0));
      // Never used:
      expect(m.revertVersions([99]), equals(0));
      expect(m, equals({'a': 1}));

      // Discarded by a rollback:
      m['a'] = 3; // v3
      m.rollback(1);
      expect(m.revertVersions([3]), equals(0));
      expect(m, equals({'a': 1}));

      // A remove left with nothing before it is dropped:
      m['b'] = 1;
      var put = m.version;
      m.remove('b');
      var removed = m.version;
      expect(m.revertVersions([put]), equals(1));
      expect(m.revertVersions([removed]), equals(0));
      expect(m, equals({'a': 1}));
    });

    test('consolidated versions: refused, before reverting anything', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['a'] = 2; // v2
      m['b'] = 1; // v3
      m['b'] = 2; // v4

      m.consolidate(3);
      expect(m.baseVersion, equals(3));
      expect(m.revertibleVersion, equals(3));

      // v4 is revertible, v2 isn't: nothing is reverted.
      expect(() => m.revertVersions([4, 2]), throwsStateError);
      expect(m, equals({'a': 2, 'b': 2}));

      // From the base on: its previous entry is kept.
      expect(m.revertVersions([4]), equals(1));
      expect(m, equals({'a': 2, 'b': 1}));
      expect(m.revertVersions([3]), equals(1));
      expect(m, equals({'a': 2}));
    });

    test('rollback and consolidate after a revert', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['a'] = 2; // v2: reverted
      m['b'] = 1; // v3
      m['a'] = 3; // v4

      m.revertVersions([2]);
      expect(m, equals({'a': 3, 'b': 1}));

      // To a reverted version: the state without it. The version is the
      // target (2), not the entry found (1): 2 isn't used again.
      expect(m.rollback(2)?.value, equals(1));
      expect(m, equals({'a': 1}));
      expect(m.version, equals(2));

      m['b'] = 5;
      expect(m.version, equals(3));
      m['a'] = 6;
      var revertible = m.version;
      m['b'] = 7;
      expect(m.consolidate(revertible), equals(revertible));
      expect(m, equals({'a': 6, 'b': 7}));
      expect(m.revertVersions([revertible]), equals(1));
      expect(m, equals({'a': 1, 'b': 7}));
    });

    test('a rollback to a reverted version: the version is not reused', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2: writer A
      var a = [m.version];
      m['a'] = 3; // v3

      m.revertVersions(a); // A aborts
      m.rollback(2); // someone rolls back to v2 (reverted)
      expect(m, equals({'a': 1}));
      expect(m.version, equals(2));

      // Writer C: v3 (not v2, A's).
      m['c'] = 9;
      expect(m.version, equals(3));

      // A retries its abort: nothing (it used to remove C's write).
      expect(m.revertVersions(a), equals(0));
      expect(m, equals({'a': 1, 'c': 9}));
    });

    test('a rollback leaving no entry keeps the target version', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2
      m.revertVersions([1, 2]);
      expect(m, isEmpty);

      expect(m.rollback(1), isNull);
      expect(m, isEmpty);
      expect(m.version, equals(1));

      m['c'] = 3;
      expect(m.version, equals(2));
      expect(m.revertVersions([1]), equals(0));
      expect(m, equals({'c': 3}));
    });

    test('several deletions left with nothing before them: dropped', () {
      var m = MapHistory<String, int>();
      m['k'] = 1; // v1
      m.remove('k'); // v2
      m['k'] = 2; // v3
      m.remove('k'); // v4

      // [v1, v2 del, v4 del]: the second deletion is kept (after another
      // one, it would still delete what a revert leaves before it).
      expect(m.revertVersions([3]), equals(1));
      expect(m, isEmpty);

      // [v2 del, v4 del]: nothing before them, both dropped.
      expect(m.revertVersions([1]), equals(1));
      expect(m, isEmpty);
      expect(m.containsKey('k'), isFalse);
      expect(m.revertVersions([2]), equals(0));
      expect(m.revertVersions([4]), equals(0));

      // The key works as new:
      m['k'] = 5;
      expect(m, equals({'k': 5}));
      expect(m.length, equals(1));
    });

    test('a deletion after another one still deletes', () {
      var m = MapHistory<String, int>();
      m['k'] = 1; // v1: writer X
      m.remove('k'); // v2: writer B
      m['k'] = 2; // v3: writer A
      m.remove('k'); // v4: writer C

      // A aborts: [v1, v2 del, v4 del].
      m.revertVersions([3]);
      // B aborts: C's deletion still removes X's value.
      expect(m.revertVersions([2]), equals(1));
      expect(m, isEmpty);

      // C aborts too: X's value is back.
      expect(m.revertVersions([4]), equals(1));
      expect(m, equals({'k': 1}));
    });

    test('versions 0 or less: never used, skipped', () {
      var m = MapHistory<String, int>();
      m['a'] = 1;

      expect(m.revertVersions([0]), equals(0));
      expect(m.revertVersions([-1, 0]), equals(0));
      expect(m, equals({'a': 1}));

      // Also after a consolidate: not "consolidated".
      m['a'] = 2;
      m.consolidate(m.version);
      expect(m.revertVersions([0, -5]), equals(0));
      expect(() => m.revertVersions([1]), throwsStateError);
    });

    test('multi-key operations: one version per key, reverted whole', () {
      var m = MapHistory<String, int>();
      m['a'] = 1;
      m['b'] = 2;

      var before = m.version;
      m.addAll({'x': 1, 'y': 2, 'z': 3});
      var addAll = [for (var v = before + 1; v <= m.version; ++v) v];
      expect(addAll.length, equals(3));

      // Only the last version: only `z` (the doc's range is all of them).
      expect(m.revertVersions([m.version]), equals(1));
      expect(m, equals({'a': 1, 'b': 2, 'x': 1, 'y': 2}));
      expect(m.revertVersions(addAll), equals(2));
      expect(m, equals({'a': 1, 'b': 2}));

      before = m.version;
      m.updateAll((k, v) => v * 10);
      var updateAll = [for (var v = before + 1; v <= m.version; ++v) v];
      expect(m, equals({'a': 10, 'b': 20}));

      before = m.version;
      m.removeWhere((k, v) => k == 'a');
      var removeWhere = [for (var v = before + 1; v <= m.version; ++v) v];
      expect(m, equals({'b': 20}));

      before = m.version;
      m.clear();
      var clear = [for (var v = before + 1; v <= m.version; ++v) v];
      expect(m, isEmpty);

      // In any order:
      expect(m.revertVersions(updateAll), equals(2));
      expect(m, isEmpty);
      expect(m.revertVersions(clear), equals(1));
      expect(m, equals({'b': 2}));
      expect(m.revertVersions(removeWhere), equals(1));
      expect(m, equals({'a': 1, 'b': 2}));
    });

    test('versions and keys may be iterated only once', () {
      var m = MapHistory<String, int>();
      m['a'] = 1;
      m['a'] = 2;
      m['b'] = 3;

      expect(
          m.revertVersions(_OneShotIterable([2, 3]),
              keys: _OneShotIterable(['a', 'b'])),
          equals(2));
      expect(m, equals({'a': 1}));

      // Lazy (generated) iterables too:
      m['c'] = 4;
      var v = m.version;
      expect(
          m.revertVersions([v].map((e) => e), keys: ['c'].where((k) => true)),
          equals(1));
      expect(m, equals({'a': 1}));
    });

    test('the map API after reverts', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1
      m['b'] = 2; // v2
      m.remove('a'); // v3
      m['c'] = 3; // v4

      m.revertVersions([3, 4]);

      expect(m, equals({'a': 1, 'b': 2}));
      expect(m.length, equals(2));
      expect(m.isNotEmpty, isTrue);
      expect(m['a'], equals(1));
      expect(m['c'], isNull);
      expect(m.containsKey('c'), isFalse);
      expect(m.containsValue(1), isTrue);
      expect(m.containsValue(3), isFalse);
      expect(m.keys, equals(['a', 'b']));
      expect(m.values, equals([1, 2]));
      expect(
          {for (var e in m.entries) e.key: e.value}, equals({'a': 1, 'b': 2}));

      var visited = <String, int>{};
      m.forEach((k, v) => visited[k] = v);
      expect(visited, equals({'a': 1, 'b': 2}));

      // The reverted operations are no longer found:
      expect(m.findOperationEntryByVersion(4), isNull);
      expect(m.findOperationEntryByVersion(1)?.value, equals(1));

      // Writing over a reverted key, or one whose deletion was reverted:
      expect(m.putIfAbsent('c', () => 30), equals(30));
      expect(m.putIfAbsent('a', () => 99), equals(1));
      expect(m.update('a', (v) => v + 1), equals(2));
      m.updateAll((k, v) => v * 10);
      expect(m, equals({'a': 20, 'b': 20, 'c': 300}));

      expect(m.map((k, v) => MapEntry(v, k)), equals({20: 'b', 300: 'c'}));
      expect(m.cast<String, num>(), equals({'a': 20, 'b': 20, 'c': 300}));

      // All reverted: empty, and works as new.
      m.revertVersions(List.generate(m.version, (i) => i + 1));
      expect(m, isEmpty);
      expect(m.length, equals(0));
      expect(m.keys, isEmpty);
      m['z'] = 1;
      expect(m, equals({'z': 1}));
      expect(m.length, equals(1));
    });

    test('the base version after reverting the first entries', () {
      var m = MapHistory<String, int>();
      m['a'] = 1; // v1: the first entry of all
      m['b'] = 1; // v2
      m['b'] = 2; // v3

      // `a` (v1) reverted: the minimal first version is now `b`'s (v2).
      m.revertVersions([1]);
      expect(m.consolidate(1), equals(2));
      expect(m.baseVersion, equals(2));
      m.rollback(2);
      expect(m, equals({'b': 1}));

      // All reverted, then a new first key: its version is the minimal.
      var m2 = MapHistory<String, int>();
      m2['a'] = 1; // v1
      m2['b'] = 1; // v2
      m2.revertVersions([1, 2]);
      m2['c'] = 1; // v3
      m2['c'] = 2; // v4
      expect(m2.consolidate(1), equals(3));
      m2.rollback(3);
      expect(m2, equals({'c': 1}));
    });

    test('a revert keeps lastTime (the last change made)', () async {
      var m = MapHistory<String, int>();
      m['a'] = 1;
      await Future<void>.delayed(Duration(milliseconds: 5));
      m['a'] = 2;
      var last = m.lastTime;

      m.revertVersions([m.version]);
      expect(m.lastTime, equals(last));
      expect(m, equals({'a': 1}));
    });

    test('many keys: length, keys and values stay consistent', () {
      var m = MapHistory<int, int>();
      for (var i = 0; i < 100; ++i) {
        m[i] = i;
      }
      var written = <int>[];
      for (var i = 0; i < 100; i += 2) {
        m.remove(i);
        written.add(m.version);
        m[i + 1000] = i;
        written.add(m.version);
      }
      expect(m.length, equals(100));

      expect(m.revertVersions(written), equals(100));
      expect(m.length, equals(100));
      expect(m.keys.toList()..sort(), equals(List.generate(100, (i) => i)));
      expect(m.values.toList()..sort(), equals(List.generate(100, (i) => i)));
      expect(m.consolidate(m.version), equals(m.version));
      expect(m.length, equals(100));
    });
  });

  group('MapHistory time', () {
    test('lastTime follows the operations', () async {
      var m = MapHistory<String, int>();
      // Before any operation: the initial time.
      expect(m.lastTime, equals(m.initialTime));

      m['a'] = 1;
      var t1 = m.lastTime;
      await Future<void>.delayed(Duration(milliseconds: 5));
      m['a'] = 2;
      // It used to keep the time of its first read (a `late final`):
      expect(m.lastTime.isAfter(t1), isTrue);
    });

    test('findOperationVersionByTime after a consolidate', () async {
      var m = MapHistory<String, int>();
      m['a'] = 1;
      m['a'] = 2;
      m['b'] = 3;
      m.consolidate(m.version);
      await Future<void>.delayed(Duration(milliseconds: 5));
      m['c'] = 4;

      // After the initial time: the operation at that time, not the base
      // (a `compareTo` result was compared to the base version).
      expect(m.findOperationVersionByTime(m.lastTime), equals(m.version));
      expect(
          m.findOperationVersionByTime(
              m.initialTime.subtract(Duration(minutes: 1))),
          equals(m.baseVersion - 1));
    });
  });
}

/// One randomized run for the `randomized` test: [steps] operations over
/// [keysCount] keys, checked against [_FullHistoryModel] after each one.
///
/// An operation over several keys (`clear`, `removeWhere`, `updateAll`)
/// gives its keys versions in the map's key order, which the model doesn't
/// follow. So rollback targets are versions between operations, and such an
/// operation is only reverted whole (all its versions): then the order
/// doesn't matter.
void _randomizedRun(int seed, {required int steps, required int keysCount}) {
  var random = Random(seed);
  var m = MapHistory<int, String>();
  var model = _FullHistoryModel();

  // Versions after each operation: valid rollback targets.
  var boundaries = <int>[0];
  // Versions of single-key writes, not yet reverted: revert candidates.
  var singleKeyWrites = <int, int>{}; // version -> key
  // Single-key writes of a value (not a removal), for the entry a rollback
  // to it returns. Apart from [singleKeyWrites]: a consolidated write is no
  // longer revertible, but may still be a rollback target.
  var singleKeyValues = <int, MapEntry<int, String>>{};
  // Multi-key operations, not yet reverted: all their versions and keys.
  var multiKeyWrites = <({Set<int> versions, Set<int> keys})>[];

  /// After a rollback to [version]: the operations after it are discarded
  /// (and their versions used again), so they are no longer rollback targets
  /// nor revert candidates.
  void dropAfter(int version) {
    boundaries.removeWhere((v) => v > version);
    singleKeyWrites.removeWhere((v, k) => v > version);
    singleKeyValues.removeWhere((v, k) => v > version);
    multiKeyWrites.removeWhere((w) => w.versions.any((v) => v > version));
  }

  /// Records a multi-key operation made after [versionBefore], over [keys]:
  /// all its versions, up to the current one, for a revert of it whole.
  void addMultiKeyWrite(int versionBefore, Iterable<int> keys) {
    if (m.version == versionBefore) return;
    multiKeyWrites.add((
      versions: {for (var v = versionBefore + 1; v <= m.version; ++v) v},
      keys: keys.toSet(),
    ));
  }

  /// [versions] (or [keys]) as one of the accepted shapes: a `List`, a `Set`
  /// or a one-shot iterable (which fails if iterated twice).
  Iterable<int> shaped(Iterable<int> values) => switch (random.nextInt(3)) {
        0 => values.toList(),
        1 => values.toSet(),
        _ => _OneShotIterable(values.toList()),
      };

  for (var step = 0; step < steps; ++step) {
    var key = random.nextInt(keysCount);
    var value = 'v$step';
    var op = random.nextInt(100);
    var versionBefore = m.version;

    String desc;
    var singleKey = false;
    if (op < 30) {
      desc = 'put($key)';
      m[key] = value;
      model.write(key, value, m.version);
      singleKeyValues[m.version] = MapEntry(key, value);
      singleKey = true;
    } else if (op < 42) {
      desc = 'remove($key)';
      m.remove(key);
      if (m.version != versionBefore) model.write(key, null, m.version);
      singleKey = true;
    } else if (op < 46) {
      desc = 'putIfAbsent($key)';
      var prev = m[key];
      var v = m.putIfAbsent(key, () => value);
      if (m.version != versionBefore) {
        model.write(key, value, m.version);
        singleKeyValues[m.version] = MapEntry(key, value);
      } else {
        // Present: its value, no operation.
        expect(v, equals(prev), reason: 'seed: $seed ; $desc');
      }
      singleKey = true;
    } else if (op < 50) {
      desc = 'update($key)';
      var v = m.update(key, (v) => '$v.', ifAbsent: () => value);
      model.write(key, v, m.version);
      singleKeyValues[m.version] = MapEntry(key, v);
      singleKey = true;
    } else if (op < 52) {
      desc = 'clear';
      var live = m.keys.toList();
      m.clear();
      model.writeMany({for (var k in live) k: null}, versionBefore, m.version);
      addMultiKeyWrite(versionBefore, live);
    } else if (op < 54) {
      desc = 'removeWhere(odd)';
      var odd = m.keys.where((k) => k.isOdd).toList();
      m.removeWhere((k, v) => k.isOdd);
      model.writeMany({for (var k in odd) k: null}, versionBefore, m.version);
      addMultiKeyWrite(versionBefore, odd);
    } else if (op < 56) {
      desc = 'updateAll';
      m.updateAll((k, v) => '$v!');
      model.writeMany(m.toMap(), versionBefore, m.version);
      addMultiKeyWrite(versionBefore, m.keys);
    } else if (op < 68) {
      // Rollback to a version between operations, from the base on (or,
      // rarely, before it: the map is cleared).
      var valid = boundaries.where((v) => v >= m.baseVersion).toList();
      if (valid.isEmpty || random.nextInt(20) == 0) {
        var target = m.baseVersion - 1;
        desc = 'rollback($target) [before base]';
        var zero = m.revertibleVersion - 1;
        expect(m.rollback(target), isNull, reason: 'seed: $seed ; $desc');
        model.clear();
        // Cleared, back to the consolidated version: every write recorded
        // is gone (nothing to roll back to, or revert, any more).
        expect(m.isEmpty, isTrue, reason: 'seed: $seed ; $desc');
        expect(m.version, equals(zero), reason: 'seed: $seed ; $desc');
        boundaries.clear();
        singleKeyWrites.clear();
        singleKeyValues.clear();
        multiKeyWrites.clear();
      } else {
        var target = valid[random.nextInt(valid.length)];
        desc = 'rollback($target)';
        var expectedEntry = singleKeyValues[target];
        var entry = m.rollback(target);
        // The target (not the entry found: no version up to it is reused).
        expect(m.version, equals(target), reason: 'seed: $seed ; $desc');
        model.rollback(target);
        // To a single-key write of a value (still in the history): its
        // entry. (Not checked for a removal: one a revert left with nothing
        // before it was dropped, and the entry is then the previous one.)
        if (expectedEntry != null) {
          expect(entry?.key, equals(expectedEntry.key),
              reason: 'seed: $seed ; $desc');
          expect(entry?.value, equals(expectedEntry.value),
              reason: 'seed: $seed ; $desc');
        }
      }
      dropAfter(m.version);
      boundaries.add(m.version);
    } else if (op < 78) {
      var target = random.nextInt(m.version + 3) - 1;
      desc = 'consolidate($target)';
      var before = m.toMap();
      var baseBefore = m.baseVersion;
      var zeroBefore = m.revertibleVersion - 1;
      var base = m.consolidate(target);
      var reason = 'seed: $seed ; $desc';
      expect(m.toMap(), equals(before), reason: reason);
      expect(base, equals(m.baseVersion), reason: reason);
      expect(m.version, equals(versionBefore), reason: reason);
      if (target <= zeroBefore) {
        // Already consolidated there: nothing changes.
        expect(base, equals(baseBefore), reason: reason);
      } else if (target > m.version) {
        // All the history:
        expect(base, equals(m.version), reason: reason);
        expect(m.revertibleVersion, equals(m.version + 1), reason: reason);
      } else {
        // Not before the target (its history is gone), and never back:
        expect(base, greaterThanOrEqualTo(target), reason: reason);
        expect(base, greaterThanOrEqualTo(baseBefore), reason: reason);
      }
      // The model keeps its history, but the map no longer can revert them:
      var revertible = m.revertibleVersion;
      singleKeyWrites.removeWhere((v, k) => v < revertible);
      multiKeyWrites.removeWhere((w) => w.versions.any((v) => v < revertible));
    } else {
      // Revert a few single-key writes and, sometimes, whole multi-key
      // operations (a "writer" aborting); sometimes with their keys (plus
      // others and duplicates), sometimes one before the base (refused).
      var candidates = singleKeyWrites.keys.toList()..shuffle(random);
      var versions = candidates.take(1 + random.nextInt(4)).toList();
      var keysOf = {for (var v in versions) singleKeyWrites[v]!};
      var multi = <({Set<int> versions, Set<int> keys})>[];
      if (multiKeyWrites.isNotEmpty && random.nextInt(3) == 0) {
        multi.add(multiKeyWrites[random.nextInt(multiKeyWrites.length)]);
        for (var w in multi) {
          versions.addAll(w.versions);
          keysOf.addAll(w.keys);
        }
      }
      if (m.revertibleVersion > 1 && random.nextInt(15) == 0) {
        var consolidated = m.revertibleVersion - 1;
        desc = 'revertVersions($consolidated) [consolidated]';
        var before = m.toMap();
        expect(() => m.revertVersions([...versions, consolidated]),
            throwsStateError,
            reason: 'seed: $seed ; $desc');
        expect(m.toMap(), equals(before), reason: 'seed: $seed ; $desc');
      } else {
        // `keys`: none, exactly the ones changed, or with others (and
        // duplicates): only the ones holding the versions matter.
        var keysMode = random.nextInt(3);
        Iterable<int>? keys = switch (keysMode) {
          0 => null,
          1 => shaped(keysOf),
          _ => shaped([
              ...keysOf,
              ...keysOf,
              random.nextInt(keysCount),
              keysCount + 100,
            ]),
        };
        desc = 'revertVersions($versions, keysMode: $keysMode, '
            'multi: ${multi.length})';
        var reverted = m.revertVersions(shaped(versions), keys: keys);
        // Fewer when a revert dropped a remove left with nothing before it
        // (no longer in the history): the state is checked below.
        expect(reverted, lessThanOrEqualTo(versions.toSet().length),
            reason: 'seed: $seed ; $desc');
        model.revert(versions.toSet());
        for (var v in versions) {
          singleKeyWrites.remove(v);
          singleKeyValues.remove(v);
        }
        multiKeyWrites.removeWhere((w) => multi.contains(w));
        // Reverted: a second time finds nothing.
        expect(m.revertVersions(versions), equals(0),
            reason: 'seed: $seed ; $desc [again]');
      }
    }

    if (singleKey && m.version != versionBefore) {
      singleKeyWrites[m.version] = key;
    }
    if (boundaries.isEmpty || boundaries.last != m.version) {
      boundaries.add(m.version);
    }
    // Only a rollback moves the version back:
    if (!desc.startsWith('rollback')) {
      expect(m.version, greaterThanOrEqualTo(versionBefore),
          reason: 'seed: $seed ; step: $step ; $desc');
    }

    var reason = 'seed: $seed ; step: $step ; $desc';
    var expected = model.state();
    expect(m.toMap(), equals(expected), reason: reason);
    expect(m.length, equals(expected.length), reason: reason);
    expect(m.isEmpty, equals(expected.isEmpty), reason: reason);
    expect(m.keys.toSet(), equals(expected.keys.toSet()), reason: reason);
    for (var k = 0; k < keysCount; ++k) {
      expect(m.containsKey(k), equals(expected.containsKey(k)),
          reason: '$reason ; key: $k');
      expect(m[k], equals(expected[k]), reason: '$reason ; key: $k');
    }
    _expectReadViewsConsistent(m, expected, reason);

    expect(m.baseVersion, lessThanOrEqualTo(m.version), reason: reason);
    // The same, except when the whole history is consolidated:
    expect(
      m.revertibleVersion == m.baseVersion ||
          (m.baseVersion == m.version && m.revertibleVersion == m.version + 1),
      isTrue,
      reason: '$reason ; base: ${m.baseVersion} ; '
          'revertible: ${m.revertibleVersion} ; version: ${m.version}',
    );
  }
}

/// Checks every read view of [m] (`isNotEmpty`, `values`, `entries`,
/// `forEach`, `containsValue`) against the [expected] content: the views are
/// computed apart from `toMap`, from the same history lists.
void _expectReadViewsConsistent(
    MapHistory<int, String> m, Map<int, String> expected, String reason) {
  expect(m.isNotEmpty, equals(expected.isNotEmpty), reason: reason);
  expect(m.keys.length, equals(expected.length), reason: reason);
  expect(m.values.toList()..sort(), equals(expected.values.toList()..sort()),
      reason: reason);
  expect({for (var e in m.entries) e.key: e.value}, equals(expected),
      reason: reason);

  var visited = <int, String>{};
  m.forEach((k, v) => visited[k] = v);
  expect(visited, equals(expected), reason: reason);

  // `keys`, `values` and `entries` iterate in the same order:
  expect(m.entries.map((e) => e.key).toList(), equals(m.keys.toList()),
      reason: reason);
  expect(m.entries.map((e) => e.value).toList(), equals(m.values.toList()),
      reason: reason);

  for (var v in expected.values) {
    expect(m.containsValue(v), isTrue, reason: '$reason ; value: $v');
  }
  expect(m.containsValue('absent'), isFalse, reason: reason);
}

/// An [Iterable] that can be iterated only once, like a generator over a
/// stream of input: [MapHistory.revertVersions] must not iterate its
/// arguments twice.
class _OneShotIterable<T> extends Iterable<T> {
  final List<T> _values;
  bool _iterated = false;

  _OneShotIterable(this._values);

  @override
  Iterator<T> get iterator {
    if (_iterated) {
      throw StateError('Iterated twice');
    }
    _iterated = true;
    return _values.iterator;
  }
}

/// The model for [_randomizedRun]: every write ever made, in order, never
/// trimmed. The state is each key's last remaining write.
class _FullHistoryModel {
  final List<_ModelWrite> _writes = [];

  void write(int key, String? value, int version) =>
      _writes.add(_ModelWrite(key, version, value));

  /// An operation over several keys, made between [versionBefore] and
  /// [versionAfter]: its keys get versions in that range (the exact one per
  /// key doesn't matter: only the range is a rollback target).
  void writeMany(
      Map<int, String?> values, int versionBefore, int versionAfter) {
    assert(versionAfter - versionBefore == values.length);
    var ver = versionBefore;
    for (var e in values.entries) {
      _writes.add(_ModelWrite(e.key, ++ver, e.value));
    }
  }

  void rollback(int targetVersion) =>
      _writes.removeWhere((w) => w.version > targetVersion);

  void revert(Set<int> versions) =>
      _writes.removeWhere((w) => versions.contains(w.version));

  void clear() => _writes.clear();

  Map<int, String> state() {
    var last = <int, String?>{};
    for (var w in _writes) {
      last[w.key] = w.value;
    }
    return {
      for (var e in last.entries)
        if (e.value != null) e.key: e.value!,
    };
  }
}

/// A write of [_FullHistoryModel]: [key] set to [value] (`null`: removed)
/// at [version].
class _ModelWrite {
  final int key;
  final int version;
  final String? value;

  _ModelWrite(this.key, this.version, this.value);
}

extension _MapEntryExntesion<K, V> on MapEntry<K, V> {
  bool equals(MapEntry<K, V> other) => key == other.key && value == other.value;
}
