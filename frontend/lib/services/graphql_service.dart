import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static const String _apiUrl = 'http://localhost:8080/graphql';

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(_apiUrl),
      cache: GraphQLCache(),
    ),
  );

  // Query to get all receipts
  static const String getAllReceiptsQuery = r'''
    query GetAllReceipts {
      receipts {
        id
        receiptId
        filename
        contentType
        fileSize
        driveFileId
        driveFileUrl
        uploadedAt
        lastAccessedAt
        userId
        category
        amount
        currency
        billDate
        vendor
      }
    }
  ''';

  // Query to get receipts by user
  static const String getReceiptsByUserQuery = r'''
    query GetReceiptsByUser($userId: String!) {
      receiptsByUser(userId: $userId) {
        id
        receiptId
        filename
        contentType
        fileSize
        driveFileId
        driveFileUrl
        uploadedAt
        lastAccessedAt
        userId
        category
        amount
        currency
        billDate
        vendor
      }
    }
  ''';

  // Query to get a single receipt
  static const String getReceiptQuery = r'''
    query GetReceipt($receiptId: String!) {
      receipt(receiptId: $receiptId) {
        id
        receiptId
        filename
        contentType
        fileSize
        driveFileId
        driveFileUrl
        uploadedAt
        lastAccessedAt
        userId
        category
        amount
        currency
        billDate
        vendor
      }
    }
  ''';

  // Mutation to delete a receipt
  static const String deleteReceiptMutation = r'''
    mutation DeleteReceipt($receiptId: String!) {
      deleteReceipt(receiptId: $receiptId)
    }
  ''';
}
