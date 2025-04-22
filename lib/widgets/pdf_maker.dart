import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

class PdfHelper {
  static Future<void> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    const taxRate = 0.0825;
    final taxAmount = invoice.cost * taxRate;
    final totalWithTax = invoice.cost + taxAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Text('BIZ-BUDDY SERVICE', style: pw.TextStyle(fontSize: 14))),
                pw.SizedBox(height: 4),
                pw.Center(child: pw.Text('(555) 123-4567', style: pw.TextStyle(fontSize: 10))),
                pw.Center(child: pw.Text('123 Biz St, Whatever City, TX', style: pw.TextStyle(fontSize: 10))),
                pw.Divider(),

                pw.Text('SERVICE: ${invoice.service}'),
                if (invoice.notes != null && invoice.notes!.isNotEmpty)
                  pw.Text('NOTES: ${invoice.notes}'),
                pw.SizedBox(height: 8),

                pw.Text('CLIENT:', style: pw.TextStyle(fontSize: 10)),
                pw.Text(invoice.clientName),
                pw.Text(invoice.clientPhone),
                pw.Text(invoice.clientAddress),
                pw.SizedBox(height: 10),

                pw.Divider(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SUBTOTAL:'),
                    pw.Text('\$${invoice.cost.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TAX (8.25%):'),
                    pw.Text('\$${taxAmount.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 12)),
                    pw.Text('\$${totalWithTax.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Text('DUE DATE: ${invoice.paymentDue}'),
                pw.SizedBox(height: 12),
                pw.Divider(),

                pw.Center(child: pw.Text('# THANK YOU! #', style: pw.TextStyle(fontSize: 12))),
                pw.SizedBox(height: 4),
                pw.Center(child: pw.Text('Printed by Biz Buddy App', style: pw.TextStyle(fontSize: 9))),

              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
