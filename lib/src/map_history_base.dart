import 'package:collection/collection.dart';

abstract class _MapEntry<K, V> {
  final DateTime time;
  final int version;

  _MapEntry(this.version, this.time);

  K get key;

  V get value;

  bool get isDeleted;

  MapEntry<K, V> get asMapEntry;
}

class _MapEntryDeleted<K, V> extends _MapEntry<K, V> {
  _MapEntryDeleted(int version, DateTime time) : super(version, time);

  @override
  bool get isDeleted => true;

  @override
  K get key => throw StateError("Deleted entry.");

  @override
  V get value => throw StateError("Deleted entry.");

  @override
  MapEntry<K, V> get asMapEntry => throw StateError("Deleted entry.");
}

class _MapEntryValue<K, V> extends _MapEntry<K, V> {
  @override
  final K key;
  @override
  final V value;

  _MapEntryValue(this.key, this.value, int version, DateTime time)
      : super(version, time);

  @override
  bool get isDeleted => false;

  @override
  MapEntry<K, V> get asMapEntry => MapEntry(key, value);
}

/// A [Map] implementation with history support, including
/// [rollback] operations.
class MapHistory<K, V> implements Map<K, V> {
  MapHistory();

  MapHistory.fromEntries(Iterable<MapEntry<K, V>> entries) {
    addEntries(entries);
  }

  MapHistory.fromIterables(Iterable<K> keys, Iterable<V> values) {
    var itrKeys = keys.iterator;
    var itrValues = values.iterator;

    while (itrKeys.moveNext() && itrValues.moveNext()) {
      _put(itrKeys.current, itrValues.current);
    }
  }

  MapHistory.from(Map<K, V> map) {
    addAll(map);
  }

  MapHistory.of(Map<K, V> map) {
    addAll(map);
  }

  int _size = 0;

  @override
  int get length => _size;

  @override
  bool get isEmpty => _size == 0;

  @override
  bool get isNotEmpty => _size > 0;

  void _computeSize() {
    _size = _entries.values
        .map((values) => values.isEmpty || values.last.isDeleted ? 0 : 1)
        .sum;
  }

  /// The initial [DateTime] of this instance. All operations are after this [DateTime].
  late final DateTime initialTime = currentTime();

  DateTime? _lastTime;

  /// The last operation [DateTime].
  late final DateTime lastTime = _lastTime ?? initialTime;

  int _version = 0;

  /// The current version of this instance.
  /// Every operation increments the version number.
  int get version => _version;

  int _incrementVersion() {
    return ++_version;
  }

  /// The current [DateTime] for new operations.
  /// Default implementation: `DateTime.now()`.
  DateTime currentTime() => DateTime.now();

  _MapEntryValue<K, V> _nextEntry(K key, V value) {
    var time = _lastTime = currentTime();
    return _MapEntryValue<K, V>(key, value, _incrementVersion(), time);
  }

  _MapEntryDeleted<K, V> _nextEntryDeleted() {
    var time = _lastTime = currentTime();
    return _MapEntryDeleted(_incrementVersion(), time);
  }

  final Map<K, List<_MapEntry<K, V>>> _entries = <K, List<_MapEntry<K, V>>>{};

  _MapEntry<K, V>? _put(K key, V value) {
    var values = _entries.putIfAbsent(key, () => <_MapEntry<K, V>>[]);
    var prev = values.lastOrNull;

    values.add(_nextEntry(key, value));

    if (prev == null || prev.isDeleted) {
      _size++;
      return null;
    } else {
      return prev;
    }
  }

  _MapEntry<K, V> _putIfAbsent(K key, V Function() ifAbsent) {
    var values = _entries.putIfAbsent(key, () => <_MapEntry<K, V>>[]);

    var prev = values.lastOrNull;

    if (prev == null || prev.isDeleted) {
      _size++;
      var value = ifAbsent();
      var entry = _nextEntry(key, value);
      values.add(entry);
      return entry;
    } else {
      return prev;
    }
  }

  _MapEntry<K, V> _update(K key, V Function(V value) update,
      {V Function()? ifAbsent}) {
    var values = _entries.putIfAbsent(key, () => <_MapEntry<K, V>>[]);

    var prev = values.lastOrNull;

    if (prev == null || prev.isDeleted) {
      if (ifAbsent == null) {
        throw ArgumentError(
            "No previous value to update for key `$key`: `ifAbsent` parameter must be provided.");
      }
      _size++;
      var value = ifAbsent();
      var entry = _nextEntry(key, value);
      values.add(entry);
      return entry;
    } else {
      var value = update(prev.value);
      var entry = _nextEntry(key, value);
      values.add(entry);
      return entry;
    }
  }

  _MapEntry<K, V>? _getLast(Object? key) {
    var prev = _entries[key]?.lastOrNull;
    return prev == null || prev.isDeleted ? null : prev;
  }

  @override
  V? operator [](Object? key) => _getLast(key)?.value;

  @override
  void operator []=(K key, V value) => _put(key, value);

  @override
  Iterable<MapEntry<K, V>> get entries => _entries.entries.where((e) {
        var values = e.value;
        return values.isNotEmpty && !values.last.isDeleted;
      }).map((e) => MapEntry(e.key, e.value.last.value));

  @override
  Iterable<K> get keys => _entries.entries.where((e) {
        var values = e.value;
        return values.isNotEmpty && !values.last.isDeleted;
      }).map((e) => e.key);

  @override
  Iterable<V> get values => _entries.values.where((value) {
        var prev = value.lastOrNull;
        return prev != null && !prev.isDeleted;
      }).map((value) => value.last.value);

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    for (var e in newEntries) {
      _put(e.key, e.value);
    }
  }

  @override
  void addAll(Map<K, V> other) => addEntries(other.entries);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _update(key, update, ifAbsent: ifAbsent).value;

  @override
  V putIfAbsent(K key, V Function() ifAbsent) =>
      _putIfAbsent(key, ifAbsent).value;

  @override
  void updateAll(V Function(K key, V value) update) {
    _entries.updateAll((key, values) {
      var prev = values.lastOrNull;
      if (prev != null && !prev.isDeleted) {
        var newValue = update(key, prev.value);
        values.add(_nextEntry(key, newValue));
      }
      return values;
    });
  }

  @override
  V? remove(Object? key) {
    var values = _entries[key];
    if (values == null || values.isEmpty) {
      return null;
    }

    var prev = values.last;
    if (prev.isDeleted) {
      return null;
    }

    --_size;
    values.add(_nextEntryDeleted());
    return prev.value;
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    for (var e in _entries.entries) {
      var values = e.value;
      if (values.isEmpty) continue;

      var prev = values.last;
      if (prev.isDeleted) continue;

      var key = e.key;
      var del = test(key, prev.value);

      if (del) {
        --_size;
        values.add(_nextEntryDeleted());
      }
    }
  }

  /// Clears all the entries.
  /// - [rollback] is still possible to rever this operation.
  @override
  void clear() {
    for (var values in _entries.values) {
      if (values.isEmpty) continue;

      var prev = values.last;
      if (prev.isDeleted) continue;

      values.add(_nextEntryDeleted());
    }

    _size = 0;
  }

  /// Returns the [MapEntry] operation for the [targetVersion].
  MapEntry<K, V>? findOperationEntryByVersion(int targetVersion) {
    for (var values in _entries.values) {
      for (var e in values) {
        if (e.version == targetVersion) {
          return e.asMapEntry;
        }
      }
    }

    return null;
  }

  /// Returns the version operation for the [targetTime],
  /// or the nearest version for [targetTime].
  int? findOperationVersionByTime(DateTime targetTime) {
    _MapEntry<K, V>? best;

    for (var values in _entries.values) {
      for (var e in values) {
        var cmp = e.time.compareTo(targetTime);
        if (cmp < 0) {
          if (best == null || best.time.compareTo(e.time) < 0) {
            best = e;
          }
        } else if (cmp == 0) {
          return e.version;
        }
      }
    }

    return best?.version;
  }

  /// Rollbacks to the operation of [targetVersion].
  MapEntry<K, V>? rollback(int targetVersion) {
    if (targetVersion <= 0) {
      _clearAll();
      return null;
    } else if (targetVersion == version) {
      return findOperationEntryByVersion(targetVersion);
    } else if (targetVersion > version) {
      return null;
    }

    _MapEntry<K, V>? targetEntry;

    for (var values in _entries.values) {
      values.removeWhere((e) {
        var ver = e.version;

        if (ver < targetVersion) {
          if (targetEntry == null || targetEntry!.version < ver) {
            targetEntry = e;
          }
          return false;
        } else if (ver == targetVersion) {
          targetEntry = e;
          return false;
        } else {
          return true;
        }
      });
    }

    _entries.removeWhere((key, values) => values.isEmpty);

    _computeSize();

    var foundEntry = targetEntry;

    if (foundEntry != null) {
      _version = foundEntry.version;
      return foundEntry.asMapEntry;
    } else {
      _clearAll();
      return null;
    }
  }

  void _clearAll() {
    _entries.clear();
    _size = 0;
    _version = 0;
    _lastTime = null;
  }

  /// Remove all entries and all history entries.
  void purgeAll() {
    _clearAll();
  }

  @override
  bool containsKey(Object? key) {
    var prev = _entries[key];
    return prev != null && prev.isNotEmpty && !prev.last.isDeleted;
  }

  @override
  bool containsValue(Object? value) => _entries.values.any((values) {
        if (values.isEmpty) return false;
        var prev = values.last;
        if (prev.isDeleted) return false;
        return prev.value == value;
      });

  @override
  void forEach(void Function(K key, V value) action) {
    for (var e in _entries.entries) {
      var values = e.value;
      if (values.isEmpty) continue;
      var prev = values.last;
      if (prev.isDeleted) continue;

      action(e.key, prev.value);
    }
  }

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) =>
      MapHistory<K2, V2>.fromEntries(
          entries.map<MapEntry<K2, V2>>((e) => convert(e.key, e.value)));

  @override
  Map<RK, RV> cast<RK, RV>() =>
      MapHistory<RK, RV>.fromEntries(entries.map<MapEntry<RK, RV>>(
          (e) => MapEntry<RK, RV>(e.key as RK, e.value as RV)));

  /// Converts this instance to a standard [Map] instance.
  Map<K, V> toMap() => Map<K, V>.fromEntries(entries);

  @override
  String toString() => toMap().toString();
}
