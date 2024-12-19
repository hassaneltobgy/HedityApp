import 'package:integration_test/integration_test.dart';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await integrationDriver();
}
