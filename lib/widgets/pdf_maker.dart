import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';

// helper class to generate invoice pdf
class PdfHelper {
  // creates a pdf invoice and returns the file path
  static Future<String> generateInvoicePdf(Invoice invoice) async {
    // create a new pdf document
    final pdf = pw.Document();

    // calculate tax and total
    const taxRate = 0.0825;
    final taxAmount = invoice.cost * taxRate;
    final totalWithTax = invoice.cost + taxAmount;

    // add a page to the pdf
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // receipt printer size
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // business header
                pw.Center(child: pw.Text('BIZ-BUDDY SERVICE', style: pw.TextStyle(fontSize: 14))),
                pw.SizedBox(height: 4),
                pw.Center(child: pw.Text('(555) 123-4567', style: pw.TextStyle(fontSize: 10))),
                pw.Center(child: pw.Text('123 Biz St, Whatever City, TX', style: pw.TextStyle(fontSize: 10))),
                pw.Divider(),

                // service and notes
                pw.Text('SERVICE: ${invoice.service}'),
                if (invoice.notes != null && invoice.notes!.isNotEmpty)
                  pw.Text('NOTES: ${invoice.notes}'),
                pw.SizedBox(height: 8),

                // client information
                pw.Text('CLIENT:', style: pw.TextStyle(fontSize: 10)),
                pw.Text(invoice.clientName),
                pw.Text(invoice.clientPhone),
                pw.Text(invoice.clientAddress),
                pw.SizedBox(height: 10),

                pw.Divider(),

                // cost breakdown
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

                // payment due date
                pw.Text('DUE DATE: ${invoice.paymentDue}'),

                pw.SizedBox(height: 12),
                pw.Divider(),

                // footer
                pw.Center(child: pw.Text('# THANK YOU! #', style: pw.TextStyle(fontSize: 12))),
                pw.SizedBox(height: 4),
                pw.Center(child: pw.Text('Printed by Biz Buddy App', style: pw.TextStyle(fontSize: 9))),
              ],
            ),
          );
        },
      ),
    );

    // get the temp directory to store file
    final output = await getTemporaryDirectory();

    // define pdf file path
    final file = File('${output.path}/${invoice.clientName}_invoice.pdf');

    // write file to disk
    await file.writeAsBytes(await pdf.save());

    // return file path
    return file.path;
  }
}
