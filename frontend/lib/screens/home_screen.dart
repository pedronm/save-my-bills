import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/receipt.dart';
import '../services/graphql_service.dart';
import '../services/database_service.dart';
import 'upload_screen.dart';
import 'receipt_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Receipt> _localReceipts = [];
  bool _showLocalData = false;

  @override
  void initState() {
    super.initState();
    _loadLocalReceipts();
  }

  Future<void> _loadLocalReceipts() async {
    final receipts = await DatabaseService.instance.getAllReceipts();
    setState(() {
      _localReceipts = receipts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save My Bills'),
        actions: [
          IconButton(
            icon: Icon(_showLocalData ? Icons.cloud : Icons.storage),
            onPressed: () {
              setState(() {
                _showLocalData = !_showLocalData;
              });
            },
            tooltip: _showLocalData ? 'Show Cloud Data' : 'Show Local Data',
          ),
        ],
      ),
      body: _showLocalData ? _buildLocalView() : _buildCloudView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
          _loadLocalReceipts();
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildLocalView() {
    if (_localReceipts.isEmpty) {
      return const Center(
        child: Text('No local receipts found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLocalReceipts,
      child: ListView.builder(
        itemCount: _localReceipts.length,
        itemBuilder: (context, index) {
          final receipt = _localReceipts[index];
          return _buildReceiptTile(receipt);
        },
      ),
    );
  }

  Widget _buildCloudView() {
    return Query(
      options: QueryOptions(
        document: gql(GraphQLService.getAllReceiptsQuery),
        pollInterval: const Duration(seconds: 10),
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${result.exception.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: refetch,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final receipts = result.data?['receipts'] as List?;

        if (receipts == null || receipts.isEmpty) {
          return const Center(
            child: Text('No receipts found'),
          );
        }

        // Save to local database
        for (var data in receipts) {
          final receipt = Receipt.fromJson(data);
          DatabaseService.instance.insertReceipt(receipt);
        }

        return RefreshIndicator(
          onRefresh: () async {
            refetch?.call();
          },
          child: ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = Receipt.fromJson(receipts[index]);
              return _buildReceiptTile(receipt);
            },
          ),
        );
      },
    );
  }

  Widget _buildReceiptTile(Receipt receipt) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.receipt, size: 40),
        title: Text(receipt.filename),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (receipt.vendor != null) Text('Vendor: ${receipt.vendor}'),
            if (receipt.amount != null)
              Text('Amount: ${receipt.currency ?? 'USD'} ${receipt.amount!.toStringAsFixed(2)}'),
            Text('Uploaded: ${dateFormat.format(receipt.uploadedAt)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (receipt.category != null)
              Chip(
                label: Text(receipt.category!),
                backgroundColor: Colors.green.shade100,
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(receipt: receipt),
            ),
          );
        },
      ),
    );
  }
}
