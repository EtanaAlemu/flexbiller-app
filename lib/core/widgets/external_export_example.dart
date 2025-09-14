import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/export_service.dart';
import '../../features/accounts/domain/entities/account.dart';

/// Example widget demonstrating how to use external storage export functionality
/// with Android 15 compliance
class ExternalExportExample extends StatefulWidget {
  final List<Account> accounts;

  const ExternalExportExample({Key? key, required this.accounts})
    : super(key: key);

  @override
  State<ExternalExportExample> createState() => _ExternalExportExampleState();
}

class _ExternalExportExampleState extends State<ExternalExportExample> {
  final ExportService _exportService = GetIt.instance<ExportService>();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CSV Export (tries external storage first, falls back to internal)
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportCSV,
          icon: const Icon(Icons.download),
          label: const Text('Export CSV'),
        ),

        const SizedBox(height: 16),

        // Excel Export (tries external storage first, falls back to internal)
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportExcel,
          icon: const Icon(Icons.table_chart),
          label: const Text('Export Excel'),
        ),

        if (_isExporting)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Future<void> _exportCSV() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await _exportService.exportAccountsToCSV(
        widget.accounts,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exported to: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await _exportService.exportAccountsToExcel(
        widget.accounts,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel exported to: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
}
