## 1.0.8

- New `revertVersions`: reverts only the operations of the given versions,
  keeping every other one, including later ones on the same keys. Unlike
  `rollback`, which discards every operation after a version, whoever made
  it. This lets concurrent writers sharing the map (e.g. transactions)
  revert only their own writes. An optional `keys` limits the search to
  the keys changed.
  - It doesn't change `version`: a version is never used again, so the
    versions other writers recorded stay valid.
  - An operation over several keys (`addAll`, `updateAll`, `clear`, …)
    uses one version per key: a writer records all of them.
  - Versions no longer in the history are skipped (`0` or less too).
    Consolidated ones are refused with a `StateError`, before anything is
    reverted.
- New `revertibleVersion`: the minimal version `revertVersions` can revert,
  the first one after the consolidated history.
- Fixes in `consolidate`:
  - It keeps the entry in effect at the target version. It used to remove
    a key's first entry whenever the key had more than 2, even when the
    next one came after the target: a `rollback` to the target then lost
    that key's value.
  - A target after the current `version` keeps the entries and removes all
    the history. It used to clear the map, entries included.
  - `baseVersion` is not before the target version. It used to be the
    minimal first version of the kept entries, which allowed a `rollback`
    to a version whose history was gone, giving a wrong state.
- Fixes in `rollback`:
  - Rolling back to the current `version` changes nothing. It used to
    clear the map when the whole history was consolidated.
  - **Behavior change**: `version` becomes the target version, not the
    version of the entry found at or before it. Those differ when the
    operations between were reverted, or when a key kept an entry from
    before the consolidated history. The next operations reused the
    versions in between, which writers may have recorded: a retried
    `revertVersions` then removed someone else's new write.
- Fixes in time:
  - `lastTime` follows the operations made. It was a `late final`, so it
    kept the time of its first read. A `rollback` or `revertVersions`
    doesn't change it.
  - `findOperationVersionByTime` compared a `compareTo` result with the
    base version. After a `consolidate`, a time before `initialTime` didn't
    give the base.
- Tests:
  - The randomized test checks against a model that never trims its
    history, instead of a copy of the previous algorithm, which had the
    same `consolidate` bug.
    - It covers `revertVersions`: single-key writes and whole multi-key
      operations, with and without `keys` (plus extra keys and
      duplicates), and as a `List`, a `Set` or a one-shot iterable.
    - After each step it checks every read view (`[]`, `keys`, `values`,
      `entries`, `forEach`, `containsKey`, `containsValue`), `version`
      after a rollback, `baseVersion` after a consolidate, and the entry a
      rollback returns.
    - It adds a run over few keys, for more conflicts.
  - New cases for `revertVersions`:
    - lost updates, inserts and deletes;
    - interleaved writers, and a deletion after another one;
    - multi-key operations, and one-shot iterables;
    - skipped (`0` and less) and consolidated versions;
    - version reuse after a rollback;
    - the map API after reverts, and the base version after reverting
      the first entries.
  - Checked by putting back the previous `consolidate` and `rollback`: the
    randomized test and the explicit cases fail.

## 1.0.7

- `consolidate` now visits only the keys changed since they were last
  consolidated, instead of every key: O(changed keys), not O(map size).
  - The minimal first version (for `baseVersion`) is kept between calls, and
    only recomputed over every key when the key holding it is consolidated.
  - Results are unchanged: a new randomized test checks `consolidate` and
    `rollback` against the previous algorithm.
  - Measured in `bones_api`'s `DBSQLMemoryAdapter`, which consolidates its
    tables on every commit: up to 12x faster writes on a table of a few
    thousand rows.
- `update` without `ifAbsent` on a missing key no longer leaves an empty
  history entry for that key behind before throwing.

## 1.0.6

- `README.md`: Fix CI badge.

## 1.0.5

- test: ^1.25.12
- dependency_validator: ^4.1.2

## 1.0.4

- sdk: '>=3.0.0 <4.0.0'

- collection: ^1.18.0
- dependency_validator: ^4.1.1

- lints: ^4.0.0
- test: ^1.25.9

## 1.0.3

- Fix minor bug when rollback target version contains a deleted entry.

## 1.0.2

- Added `consolidate` and `baseVersion`.

## 1.0.1

- Minor fixes.
- Improved test coverage to +90%

## 1.0.0

- Initial version.
