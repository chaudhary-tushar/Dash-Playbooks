import 'package:flutbook/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Entity', () {
    test('should create valid User instance', () {
      // Arrange
      const userId = 'user123';
      const email = 'test@example.com';
      const displayName = 'Test User';
      const authMethod = 'email_password';
      const createdAt = '2023-01-01T00:00:00Z';
      const updatedAt = '2023-01-02T00:00:00Z';

      // Act
      final user = User(
        id: userId,
        email: email,
        displayName: displayName,
        authMethod: authMethod,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(user.id, userId);
      expect(user.email, email);
      expect(user.displayName, displayName);
      expect(user.authMethod, authMethod);
      expect(user.createdAt, createdAt);
      expect(user.updatedAt, updatedAt);
    });

    test('should create User with optional fields', () {
      // Act
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: null,
        authMethod: 'email_password',
        createdAt: null,
        updatedAt: null,
      );

      // Assert
      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, isNull);
      expect(user.authMethod, 'email_password');
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('should support value comparison', () {
      // Arrange
      final user1 = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        authMethod: 'email_password',
      );

      final user2 = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        authMethod: 'email_password',
      );

      // Assert
      expect(user1, equals(user2));
    });

    test('should support JSON serialization', () {
      // Arrange
      final user = User(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        authMethod: 'email_password',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-02T00:00:00Z',
      );

      // Act
      final json = user.toJson();
      final fromJson = User.fromJson(json);

      // Assert
      expect(fromJson, equals(user));
      expect(json, containsPair('id', 'user123'));
      expect(json, containsPair('email', 'test@example.com'));
      expect(json, containsPair('displayName', 'Test User'));
      expect(json, containsPair('authMethod', 'email_password'));
    });
  });
}