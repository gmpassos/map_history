# map_history

[![pub package](https://img.shields.io/pub/v/map_history.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/map_history)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/map_history)](https://app.codecov.io/gh/gmpassos/map_history)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/map_history/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/map_history/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/map_history?logo=git&logoColor=white)](https://github.com/gmpassos/map_history/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/map_history/latest?logo=git&logoColor=white)](https://github.com/gmpassos/map_history/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/map_history?logo=git&logoColor=white)](https://github.com/gmpassos/map_history/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/map_history?logo=github&logoColor=white)](https://github.com/gmpassos/map_history/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/map_history?logo=github&logoColor=white)](https://github.com/gmpassos/map_history)
[![License](https://img.shields.io/github/license/gmpassos/map_history?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/map_history/blob/master/LICENSE)

A Map implementation with history and rollback support for entries, keys and values.

## Usage

Here's a simple usage example:

```dart
import 'package:map_history/map_history.dart';

void main() {
  var m = MapHistory<int, String>();

  m[1] = 'a';
  m[2] = 'b';
  m[3] = 'c';

  var ver3 = m.version;

  print('Version: $ver3 >> $m');

  m[2] = 'B';
  m.remove(3);

  var ver5 = m.version;
  print('Version: $ver5 >> $m');

  print('Rollback to version: $ver3');
  m.rollback(ver3);

  print('Version: ${m.version} >> $m');
}
```

Output:

```text
Version: 3 >> {1: a, 2: b, 3: c}
Version: 5 >> {1: a, 2: B}
Rollback to version: 3
Version: 3 >> {1: a, 2: b, 3: c}
```

## See Also

[Dart Map][dart_map] documentation.

[dart_map]: https://api.dart.dev/be/180360/dart-core/Map-class.html

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/map_history/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
