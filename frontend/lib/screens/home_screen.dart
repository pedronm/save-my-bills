import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/screenshot.dart';
import '../services/graphql_service.dart';
import '../services/database_service.dart';
import 'upload_screen.dart';
import 'screenshot_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Screenshot> _localScreenshots = [];
  bool _showLocalData = false;

  @override
  void initState() {
    super.initState();
    _loadLocalScreenshots();
  }

  Future<void> _loadLocalScreenshots() async {
    final screenshots = await DatabaseService.instance.getAllScreenshots();
    setState(() {
      _localScreenshots = screenshots;
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
          _loadLocalScreenshots();
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildLocalView() {
    if (_localScreenshots.isEmpty) {
      return const Center(
        child: Text('No local screenshots found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLocalScreenshots,
      child: ListView.builder(
        itemCount: _localScreenshots.length,
        itemBuilder: (context, index) {
          final screenshot = _localScreenshots[index];
          return _buildScreenshotTile(screenshot);
        },
      ),
    );
  }

  Widget _buildCloudView() {
    return Query(
      options: QueryOptions(
        document: gql(GraphQLService.getAllScreenshotsQuery),
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

        final screenshots = result.data?['screenshots'] as List?;

        if (screenshots == null || screenshots.isEmpty) {
          return const Center(
            child: Text('No screenshots found'),
          );
        }

        // Save to local database
        for (var data in screenshots) {
          final screenshot = Screenshot.fromJson(data);
          DatabaseService.instance.insertScreenshot(screenshot);
        }

        return RefreshIndicator(
          onRefresh: () async {
            refetch?.call();
          },
          child: ListView.builder(
            itemCount: screenshots.length,
            itemBuilder: (context, index) {
              final screenshot = Screenshot.fromJson(screenshots[index]);
              return _buildScreenshotTile(screenshot);
            },
          ),
        );
      },
    );
  }

  Widget _buildScreenshotTile(Screenshot screenshot) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.receipt, size: 40),
        title: Text(screenshot.filename),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (screenshot.vendor != null) Text('Vendor: ${screenshot.vendor}'),
            if (screenshot.amount != null)
              Text('Amount: ${screenshot.currency ?? 'USD'} ${screenshot.amount!.toStringAsFixed(2)}'),
            Text('Uploaded: ${dateFormat.format(screenshot.uploadedAt)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (screenshot.category != null)
              Chip(
                label: Text(screenshot.category!),
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
              builder: (context) => ScreenshotDetailScreen(screenshot: screenshot),
            ),
          );
        },
      ),
    );
  }
}
