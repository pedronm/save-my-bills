import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static const String _apiUrl = 'http://localhost:8080/graphql';

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(_apiUrl),
      cache: GraphQLCache(),
    ),
  );

  // Query to get all screenshots
  static const String getAllScreenshotsQuery = r'''
    query GetAllScreenshots {
      screenshots {
        id
        screenshotId
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

  // Query to get screenshots by user
  static const String getScreenshotsByUserQuery = r'''
    query GetScreenshotsByUser($userId: String!) {
      screenshotsByUser(userId: $userId) {
        id
        screenshotId
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

  // Query to get a single screenshot
  static const String getScreenshotQuery = r'''
    query GetScreenshot($screenshotId: String!) {
      screenshot(screenshotId: $screenshotId) {
        id
        screenshotId
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

  // Mutation to delete a screenshot
  static const String deleteScreenshotMutation = r'''
    mutation DeleteScreenshot($screenshotId: String!) {
      deleteScreenshot(screenshotId: $screenshotId)
    }
  ''';
}
