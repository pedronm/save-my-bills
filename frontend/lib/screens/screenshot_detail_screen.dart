import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/screenshot.dart';
import '../services/graphql_service.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class ScreenshotDetailScreen extends StatelessWidget {
  final Screenshot screenshot;

  const ScreenshotDetailScreen({super.key, required this.screenshot});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Filename', screenshot.filename),
                    _buildInfoRow('Screenshot ID', screenshot.screenshotId),
                    if (screenshot.contentType != null)
                      _buildInfoRow('Content Type', screenshot.contentType!),
                    if (screenshot.fileSize != null)
                      _buildInfoRow(
                        'File Size',
                        '${(screenshot.fileSize! / 1024).toStringAsFixed(2)} KB',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bill information
            if (screenshot.vendor != null ||
                screenshot.amount != null ||
                screenshot.category != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bill Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      if (screenshot.vendor != null)
                        _buildInfoRow('Vendor', screenshot.vendor!),
                      if (screenshot.amount != null)
                        _buildInfoRow(
                          'Amount',
                          '${screenshot.currency ?? 'USD'} ${screenshot.amount!.toStringAsFixed(2)}',
                        ),
                      if (screenshot.category != null)
                        _buildInfoRow('Category', screenshot.category!),
                      if (screenshot.billDate != null)
                        _buildInfoRow(
                          'Bill Date',
                          dateFormat.format(screenshot.billDate!),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Timestamps
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timestamps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Uploaded',
                      dateFormat.format(screenshot.uploadedAt),
                    ),
                    if (screenshot.lastAccessedAt != null)
                      _buildInfoRow(
                        'Last Accessed',
                        dateFormat.format(screenshot.lastAccessedAt!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Google Drive link
            if (screenshot.driveFileUrl != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Storage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Drive File ID', screenshot.driveFileId),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real app, you would open the URL
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('URL: ${screenshot.driveFileUrl}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('View in Google Drive'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screenshot'),
        content: const Text(
          'Are you sure you want to delete this screenshot? This will remove it from both cloud and local storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _deleteScreenshot(context);
    }
  }

  Future<void> _deleteScreenshot(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLService.deleteScreenshotMutation),
          variables: {
            'screenshotId': screenshot.screenshotId,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Also delete from local database
      await DatabaseService.instance.deleteScreenshot(screenshot.screenshotId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenshot deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
