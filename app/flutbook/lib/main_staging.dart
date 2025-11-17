import 'package:flutbook/app/app.dart';
import 'package:flutbook/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
