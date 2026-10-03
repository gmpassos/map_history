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
