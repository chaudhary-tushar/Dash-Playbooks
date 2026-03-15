// lib/features/sync/data/models/queue_item_model.dart
import 'dart:convert';

import 'package:flutbook/features/sync/domain/repositories/offline_queue_repository.dart';
import 'package:isar_community/isar.dart';

part 'queue_item_model.g.dart';

@collection
class QueueItemModel {
  // Empty constructor for Isar
  QueueItemModel();

  // Constructor from domain entity
  QueueItemModel.fromDomain(QueueItem item) {
    internalId = item.id;
    operationType = item.operationType.toString();
    tableName = item.tableName;
    recordId = item.recordId;
    try {
      data = jsonEncode(item.data);
    } catch (_) {
      data = '{}';
    }
    createdAt = item.createdAt;
    priority = item.priority;
    retryCount = item.retryCount;
    lastError = item.lastError;
    status = item.status.toString();
  }

  Id id = Isar.autoIncrement;

  /// Domain entity ID (maps to QueueItem.id)
  late String internalId;

  late String operationType;

  late String tableName;

  late String recordId;

  late String data;

  late DateTime createdAt;

  late int priority;

  late int retryCount;

  String? lastError;

  late String status;

  // Convert to domain entity
  QueueItem toDomain() {
    QueueOperationType opType = QueueOperationType.create;
    try {
      final name = operationType.split('.').last;
      opType = QueueOperationType.values.firstWhere((e) => e.toString().endsWith('.$name'));
    } catch (_) {
      opType = QueueOperationType.create;
    }

    QueueItemStatus itemStatus = QueueItemStatus.pending;
    try {
      final name = status.split('.').last;
      itemStatus = QueueItemStatus.values.firstWhere((e) => e.toString().endsWith('.$name'));
    } catch (_) {
      itemStatus = QueueItemStatus.pending;
    }

    Map<String, dynamic> itemData = {};
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        itemData = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      itemData = {};
    }

    return QueueItem(
      id: internalId,
      operationType: opType,
      tableName: tableName,
      recordId: recordId,
      data: itemData,
      createdAt: createdAt,
      priority: priority,
      retryCount: retryCount,
      lastError: lastError,
      status: itemStatus,
    );
  }
}
