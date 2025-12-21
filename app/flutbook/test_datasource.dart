import 'package:flutbook/core/services/database_service.dart';
import 'package:flutbook/features/auth/data/datasources/user_profile_datasource.dart';

void main() async {
  try {
    final databaseService = DatabaseService();
    await databaseService.init();

    final datasource = UserProfileDatasource(databaseService: databaseService);
    print(
      'UserProfileDatasource created successfully: ${datasource.runtimeType}',
    );

    // Test a simple operation
    final hasProfiles = await datasource.hasUserProfiles();
    print('Has user profiles: $hasProfiles');
  } catch (e) {
    print('Error: $e');
  }
}
