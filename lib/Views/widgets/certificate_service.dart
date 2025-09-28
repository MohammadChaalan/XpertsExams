import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class CertificateService {
  static Future<Uint8List> generateCertificate({
    required String studentName,
    required String courseName,
    required String date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 3),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Certificate of Completion",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  "This certifies that",
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  studentName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "has successfully completed the course",
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  courseName,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  "Date: $date",
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 60),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    "Instructor Signature",
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
