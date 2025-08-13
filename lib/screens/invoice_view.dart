import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceView extends StatelessWidget {
  final Map<String, dynamic> invoiceData;

  const InvoiceView({Key? key, required this.invoiceData}) : super(key: key);

  Future<void> _printInvoice() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 30),
                _buildPdfRow('Client:', invoiceData['client_name']),
                _buildPdfRow('Service:', invoiceData['service']),
                _buildPdfRow('Amount:', 'Rs.${invoiceData['amount']}'),
                _buildPdfRow('Due Date:', invoiceData['due_date']),
                _buildPdfRow('Status:', invoiceData['status']),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(flex: 3, child: pw.Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice View', textAlign: TextAlign.center),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _printInvoice),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Client:', invoiceData['client_name']),
            _buildDetailRow('Service:', invoiceData['service']),
            _buildDetailRow('Amount:', '₹${invoiceData['amount']}'),
            _buildDetailRow('Due Date:', invoiceData['due_date']),
            _buildDetailRow('Status:', invoiceData['status']),
          ],
        ),
      ),
    );
  }
}
