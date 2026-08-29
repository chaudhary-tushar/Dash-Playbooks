import 'package:flutbook/app/view/app.dart';
import 'package:flutbook/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App(), env: 'development');
}
