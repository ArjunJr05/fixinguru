import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class TaskReceiptPage extends StatelessWidget {
  final Map<String, dynamic> taskData;

  const TaskReceiptPage({
    super.key,
    required this.taskData,
  });

  @override
  Widget build(BuildContext context) {
    // Get the primary color from the context
    const primaryColor = Color(0xFF4CD964);
    const backgroundColor = Color(0xFF121212);
    const cardColor = Color(0xFF1E1E1E);
    const textColor = Colors.white;
    const secondaryTextColor = Colors.grey;

    // Calculate taxes and fees (20% of estimated budget)
    final double estimatedBudget = taskData['estimatedBudget'] ?? 0.0;
    final double finalBudget = taskData['finalBudget'] ?? 0.0;
    final double serviceFee = estimatedBudget * 0.15;
    final double tax = estimatedBudget * 0.05;
    final double totalAmount = finalBudget + serviceFee + tax;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Task Receipt Preview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Download PDF button
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () => _generateAndDownloadPDF(
                context, taskData, finalBudget, serviceFee, tax, totalAmount),
            tooltip: 'Download PDF',
          ),
        ],
        // Add a subtle gradient to the app bar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Receipt Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 24,
                          child: Icon(
                            _getCategoryIcon(taskData['category']),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                taskData['title'],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                taskData['category'],
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Task Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildReceiptRow(
                            'Date & Time',
                            '${taskData['date']} at ${taskData['time']}',
                            textColor,
                            secondaryTextColor),
                        _buildDivider(),

                        _buildReceiptRow('Location', taskData['location'],
                            textColor, secondaryTextColor),
                        _buildDivider(),

                        // Description with truncation if too long
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              taskData['description'],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (taskData['description'].toString().length > 120)
                              TextButton(
                                onPressed: () {
                                  // Show full description in a dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: cardColor,
                                      title: Text(
                                        'Task Description',
                                        style: TextStyle(color: textColor),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Text(
                                          taskData['description'],
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Close',
                                            style:
                                                TextStyle(color: primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Text(
                                  'Read more',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        _buildDivider(),
                      ],
                    ),
                  ),

                  // Cost Breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReceiptRow(
                            'Task Budget',
                            '₹${finalBudget.toStringAsFixed(2)}',
                            textColor,
                            secondaryTextColor),
                        const SizedBox(height: 8),
                        _buildReceiptRow(
                            'Service Fee (15%)',
                            '₹${serviceFee.toStringAsFixed(2)}',
                            textColor,
                            secondaryTextColor),
                        const SizedBox(height: 8),
                        _buildReceiptRow(
                            'Taxes (5%)',
                            '₹${tax.toStringAsFixed(2)}',
                            textColor,
                            secondaryTextColor),
                        const SizedBox(height: 12),
                        Divider(color: secondaryTextColor.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        _buildReceiptRow(
                            'Total Amount',
                            '₹${totalAmount.toStringAsFixed(2)}',
                            primaryColor,
                            primaryColor,
                            isBold: true,
                            isLarge: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Payment Method',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Balance',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹5,000.00',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Post Task Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Create task item to return to the tasks list
                  TaskItem newTask = TaskItem(
                    name: taskData['title'],
                    icon: _getCategoryIcon(taskData['category']),
                    color: _getCategoryColor(taskData['category']),
                    date: "Just now",
                    status: "Open",
                    category: taskData['category'],
                    budget: finalBudget,
                  );

                  // Show success animation as an overlay
                  _showSuccessToast(context, newTask);

                  // Return the new task to the previous screen but stay on this page
                  Navigator.of(context).pop(newTask);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Confirm & Post Task',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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

  // Show success toast with Lottie animation
  void _showSuccessToast(BuildContext context, TaskItem newTask) {
    const primaryColor = Color(0xFF4CD964);

    // Create an overlay entry
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // Small Lottie animation
                // Small Lottie animation
                SizedBox(
                  height: 50,
                  width: 50,
                  child: const Center(
                    child: Text(
                      '✅', // Check mark emoji
                      style: TextStyle(
                        fontSize: 28, // You can adjust the size as needed
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Task Posted Successfully!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You will be notified when someone accepts your task',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlayState.insert(overlayEntry);

    // Remove after showing animation
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // Generate PDF file for receipt
  Future<void> _generateAndDownloadPDF(
      BuildContext context,
      Map<String, dynamic> taskData,
      double finalBudget,
      double serviceFee,
      double tax,
      double totalAmount) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to save PDF')),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );

    final pdf = pw.Document();

    // Add receipt to PDF with logo and better styling
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with app logo placeholder
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Task Receipt',
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            'Receipt #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            style: const pw.TextStyle(color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text('Task',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey300, thickness: 1),
                pw.SizedBox(height: 20),

                // Task Info
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Task Details',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      _buildPdfRow('Task Title', taskData['title']),
                      _buildPdfRow('Category', taskData['category']),
                      _buildPdfRow('Date & Time',
                          '${taskData['date']} at ${taskData['time']}'),
                      _buildPdfRow('Location', taskData['location']),
                      pw.SizedBox(height: 15),
                      pw.Text('Description:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(taskData['description']),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Payment Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Payment Details',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      _buildPdfRow(
                          'Task Budget', '₹${finalBudget.toStringAsFixed(2)}'),
                      _buildPdfRow('Service Fee (15%)',
                          '₹${serviceFee.toStringAsFixed(2)}'),
                      _buildPdfRow('Taxes (5%)', '₹${tax.toStringAsFixed(2)}'),
                      pw.SizedBox(height: 5),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Amount',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('₹${totalAmount.toStringAsFixed(2)}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text('Thank you for using our service!'),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                      'Generated on ${DateTime.now().toString().split('.')[0]}',
                      style:
                          const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save PDF to Downloads folder
    try {
      final params = SaveFileDialogParams(
        data: await pdf.save(),
        fileName: 'Task_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF saved successfully'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(filePath),
            ),
            backgroundColor: const Color(0xFF4CD964),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Fallback to application documents directory
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'Task_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF saved to app storage'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(file.path),
            ),
            backgroundColor: const Color(0xFF4CD964),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper method for PDF row
  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey800)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper method to build consistent dividers
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(
        color: Colors.grey.withOpacity(0.3),
        height: 1,
      ),
    );
  }

  // Helper method to build receipt rows
  Widget _buildReceiptRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor, {
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper function to get icon for selected category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Moving':
        return Icons.local_shipping;
      case 'Assembly':
        return Icons.build;
      case 'Delivery':
        return Icons.local_shipping;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Gardening':
        return Icons.yard;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // Helper function to get color for selected category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cleaning':
        return Colors.blue;
      case 'Moving':
        return Colors.amber;
      case 'Assembly':
        return Colors.purple;
      case 'Delivery':
        return Colors.orange;
      case 'Electrical':
        return Colors.yellow;
      case 'Plumbing':
        return Colors.cyan;
      case 'Gardening':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Task item model class
class TaskItem {
  final String name;
  final IconData icon;
  final Color color;
  final String date;
  final String status;
  final String category;
  final double budget;

  TaskItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.date,
    required this.status,
    required this.category,
    required this.budget,
  });
}
