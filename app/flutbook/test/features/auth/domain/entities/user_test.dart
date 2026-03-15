import 'package:flutbook/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Entity', () {
    test('should create valid User instance', () {
      // Arrange
      const userId = 'user123';
      const email = 'test@example.com';
      const name = 'Test User';
      const photo = 'https://example.com/photo.jpg';

      // Act
      const user = User(
        id: userId,
        email: email,
        name: name,
        photo: photo,
      );

      // Assert
      expect(user.id, userId);
      expect(user.email, email);
      expect(user.name, name);
      expect(user.photo, photo);
    });

    test('should create User with optional fields', () {
      // Act
      const user = User(
        id: 'user123',
      );

      // Assert
      expect(user.id, 'user123');
      expect(user.email, isNull);
      expect(user.name, isNull);
      expect(user.photo, isNull);
    });

    test('should support value comparison', () {
      // Arrange
      const user1 = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        photo: 'https://example.com/photo.jpg',
      );

      const user2 = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        photo: 'https://example.com/photo.jpg',
      );

      // Assert
      expect(user1, equals(user2));
    });

    test('should support empty user', () {
      // Act
      const emptyUser = User.empty;

      // Assert
      expect(emptyUser.id, '');
      expect(emptyUser.email, isNull);
      expect(emptyUser.name, isNull);
      expect(emptyUser.photo, isNull);
      expect(emptyUser.isEmpty, isTrue);
      expect(emptyUser.isNotEmpty, isFalse);
    });

    test('should support non-empty user', () {
      // Act
      const user = User(id: 'user123', email: 'test@example.com');

      // Assert
      expect(user.isEmpty, isFalse);
      expect(user.isNotEmpty, isTrue);
    });

    test('should support value comparison with empty user', () {
      // Arrange
      const emptyUser1 = User.empty;
      const emptyUser2 = User.empty;

      // Assert
      expect(emptyUser1, equals(emptyUser2));
      expect(emptyUser1.isEmpty, isTrue);
      expect(emptyUser2.isEmpty, isTrue);
    });
  });
}