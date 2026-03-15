/// Supabase remote datasource for reading list synchronization.
///
/// Handles reading list synchronization with Supabase PostgreSQL database.
/// Provides CRUD operations for reading lists and list items.
library;

import 'package:flutbook/core/config/app_config.dart';
import 'package:flutbook/core/error/exceptions.dart';
import 'package:flutbook/features/sync/domain/entities/reading_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase remote datasource for reading list operations.
///
/// Handles reading list synchronization with Supabase.
class SupabaseReadingListDatasource {
  /// Create a new SupabaseReadingListDatasource.
  ///
  /// [supabase] - The Supabase client instance
  /// [configProvider] - Configuration provider for app settings
  SupabaseReadingListDatasource({
    required SupabaseClient supabase,
    required ConfigProvider configProvider,
  })  : _supabase = supabase,
        _configProvider = configProvider;

  final SupabaseClient _supabase;
  final ConfigProvider _configProvider;

  /// Get the current configuration
  AppConfig get _config => _configProvider.config;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final user = _supabase.auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get all reading lists from Supabase
  Future<List<ReadingList>> getReadingLists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('reading_lists')
          .select('''
            *,
            reading_list_items(audiobook_id)
          ''')
          .eq('user_id', user.id)
          .order('order', ascending: true);

      final lists = <ReadingList>[];
      for (final row in result) {
        final items = (row['reading_list_items'] as List?) ?? [];
        final audiobookIds = items
            .map((item) => item['audiobook_id'] as String)
            .toList();

        final list = ReadingList(
          id: row['id'] as String,
          name: row['name'] as String,
          description: row['description'] as String?,
          audiobookIds: audiobookIds,
          createdAt: row['created_at'] as DateTime,
          updatedAt: row['updated_at'] as DateTime?,
          order: (row['order'] as int?) ?? 0,
        );

        lists.add(list);
      }

      return lists;
    } catch (e) {
      throw DatabaseException('Failed to get reading lists: $e');
    }
  }

  /// Get a specific reading list by ID
  Future<ReadingList?> getReadingList(String listId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final result = await _supabase
          .from('reading_lists')
          .select('''
            *,
            reading_list_items(audiobook_id)
          ''')
          .eq('id', listId)
          .eq('user_id', user.id)
          .single();

      final items = (result['reading_list_items'] as List?) ?? [];
      final audiobookIds = items
          .map((item) => item['audiobook_id'] as String)
          .toList();

      return ReadingList(
        id: result['id'] as String,
        name: result['name'] as String,
        description: result['description'] as String?,
        audiobookIds: audiobookIds,
        createdAt: result['created_at'] as DateTime,
        updatedAt: result['updated_at'] as DateTime?,
        order: (result['order'] as int?) ?? 0,
      );
    } catch (e) {
      throw DatabaseException('Failed to get reading list: $e');
    }
  }

  /// Create a new reading list
  Future<void> createReadingList(ReadingList readingList) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final data = {
        'id': readingList.id,
        'user_id': user.id,
        'name': readingList.name,
        'description': readingList.description,
        'order': readingList.order,
        'created_at': readingList.createdAt,
        'updated_at': readingList.updatedAt ?? DateTime.now(),
      };

      await _supabase.from('reading_lists').insert(data);

      // Add audiobook items if any
      if (readingList.audiobookIds.isNotEmpty) {
        await _addAudiobookItems(readingList.id, readingList.audiobookIds);
      }
    } catch (e) {
      throw DatabaseException('Failed to create reading list: $e');
    }
  }

  /// Update an existing reading list
  Future<void> updateReadingList(ReadingList readingList) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      final data = {
        'name': readingList.name,
        'description': readingList.description,
        'order': readingList.order,
        'updated_at': readingList.updatedAt ?? DateTime.now(),
      };

      await _supabase
          .from('reading_lists')
          .update(data)
          .eq('id', readingList.id)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to update reading list: $e');
    }
  }

  /// Delete a reading list
  Future<void> deleteReadingList(String listId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Delete list items first (cascade should handle this, but being explicit)
      await _supabase
          .from('reading_list_items')
          .delete()
          .eq('list_id', listId);

      // Delete the list
      await _supabase
          .from('reading_lists')
          .delete()
          .eq('id', listId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DatabaseException('Failed to delete reading list: $e');
    }
  }

  /// Add audiobooks to a reading list
  Future<void> addAudiobookToList(String listId, String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      // Check if list exists and belongs to user
      final listExists = await _supabase
          .from('reading_lists')
          .select('id')
          .eq('id', listId)
          .eq('user_id', user.id)
          .single()
          .then((value) => true)
          .catchError((_) => false);

      if (!listExists) {
        throw NotFoundException('Reading list not found');
      }

      // Check if item already exists
      final itemExists = await _supabase
          .from('reading_list_items')
          .select('id')
          .eq('list_id', listId)
          .eq('audiobook_id', audiobookId)
          .single()
          .then((value) => true)
          .catchError((_) => false);

      if (!itemExists) {
        await _supabase.from('reading_list_items').insert({
          'list_id': listId,
          'audiobook_id': audiobookId,
          'added_at': DateTime.now(),
        });
      }
    } catch (e) {
      throw DatabaseException('Failed to add audiobook to list: $e');
    }
  }

  /// Remove audiobook from a reading list
  Future<void> removeAudiobookFromList(String listId, String audiobookId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }

      await _supabase
          .from('reading_list_items')
          .delete()
          .eq('list_id', listId)
          .eq('audiobook_id', audiobookId);
    } catch (e) {
      throw DatabaseException('Failed to remove audiobook from list: $e');
    }
  }

  /// Helper method to add multiple audiobook items
  Future<void> _addAudiobookItems(String listId, List<String> audiobookIds) async {
    final items = audiobookIds.map((id) => {
      'list_id': listId,
      'audiobook_id': id,
      'added_at': DateTime.now(),
    }).toList();

    if (items.isNotEmpty) {
      await _supabase.from('reading_list_items').insert(items);
    }
  }
}
