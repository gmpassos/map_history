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

/////////////////////////////
// OUTPUT:
/////////////////////////////
// Version: 3 >> {1: a, 2: b, 3: c}
// Version: 5 >> {1: a, 2: B}
// Rollback to version: 3
// Version: 3 >> {1: a, 2: b, 3: c}
