import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/receipt.dart';
import '../services/graphql_service.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
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
                    _buildInfoRow('Filename', receipt.filename),
                    _buildInfoRow('Receipt ID', receipt.receiptId),
                    if (receipt.contentType != null)
                      _buildInfoRow('Content Type', receipt.contentType!),
                    if (receipt.fileSize != null)
                      _buildInfoRow(
                        'File Size',
                        '${(receipt.fileSize! / 1024).toStringAsFixed(2)} KB',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bill information
            if (receipt.vendor != null ||
                receipt.amount != null ||
                receipt.category != null)
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
                      if (receipt.vendor != null)
                        _buildInfoRow('Vendor', receipt.vendor!),
                      if (receipt.amount != null)
                        _buildInfoRow(
                          'Amount',
                          '${receipt.currency ?? 'USD'} ${receipt.amount!.toStringAsFixed(2)}',
                        ),
                      if (receipt.category != null)
                        _buildInfoRow('Category', receipt.category!),
                      if (receipt.billDate != null)
                        _buildInfoRow(
                          'Bill Date',
                          dateFormat.format(receipt.billDate!),
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
                      dateFormat.format(receipt.uploadedAt),
                    ),
                    if (receipt.lastAccessedAt != null)
                      _buildInfoRow(
                        'Last Accessed',
                        dateFormat.format(receipt.lastAccessedAt!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Google Drive link
            if (receipt.driveFileUrl != null)
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
                      _buildInfoRow('Drive File ID', receipt.driveFileId),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real app, you would open the URL
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('URL: ${receipt.driveFileUrl}'),
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
        title: const Text('Delete Receipt'),
        content: const Text(
          'Are you sure you want to delete this receipt? This will remove it from both cloud and local storage.',
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
      _deleteReceipt(context);
    }
  }

  Future<void> _deleteReceipt(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLService.deleteReceiptMutation),
          variables: {
            'receiptId': receipt.receiptId,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      // Also delete from local database
      await DatabaseService.instance.deleteReceipt(receipt.receiptId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt deleted successfully'),
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
