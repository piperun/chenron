import 'package:chenron/models/item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chenron/providers/cud_state.dart';
import 'package:chenron/providers/folder_info_state.dart';
import 'package:chenron/models/cud.dart';

class FolderPreview extends StatefulWidget {
  final GlobalKey<FormState> previewKey;

  const FolderPreview({super.key, required this.previewKey});

  @override
  FolderPreviewState createState() => FolderPreviewState();
}

class FolderPreviewState extends State<FolderPreview> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildReviewCard(context),
        const SizedBox(height: 20),
        _buildExpandableSection(context),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Before Saving',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            Text(
              'Before proceeding with the save operation, please review the details below:',
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context) {
    return Column(
      children: [
        _buildExpandHeader(context),
        if (_isExpanded) _buildExpandedContent(context),
      ],
    );
  }

  Widget _buildExpandHeader(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isExpanded ? 'Collapse' : 'Expand Details',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.black87),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final folderProvider =
        Provider.of<FolderInfoProvider>(context, listen: false);
    final dataProvider =
        Provider.of<CUDProvider<FolderItem>>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(context, 'Title', folderProvider.title),
          _buildInfoRow(context, 'Description', folderProvider.description),
          _buildInfoRow(context, 'Tags', folderProvider.tags.join(', ')),
          _buildInfoRow(context, 'Links', dataProvider.create.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}
