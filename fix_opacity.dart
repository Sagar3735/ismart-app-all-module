import 'dart:io';

void main() {
  final f = File('lib/screens/home/home_screen.dart');
  var content = f.readAsStringSync();
  content = content.replaceAllMapped(RegExp(r'\.withOpacity\((.*?)\)'), (m) => '.withValues(alpha: ${m[1]})');
  f.writeAsStringSync(content);
}
