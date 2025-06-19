import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generateFraudTransactionPdf(
  Map<String, dynamic> transactionData,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.Text(
              "Fraud Transaction Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Report Summary
            pw.Text(
              "Report Summary:",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              transactionData["report_summary"] ?? "No summary available",
            ),
            pw.SizedBox(height: 10),

            // Risk Evaluation
            pw.Text(
              "Risk Evaluation:",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "Overall Risk Score: ${transactionData["risk_evaluation"]["overall_risk_score"] ?? "N/A"}",
            ),
            pw.SizedBox(height: 10),

            // Risk Factors
            pw.Text(
              "Risk Factors:",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...List.generate(
              transactionData["risk_evaluation"]["risk_factors"]?.length ?? 0,
              (index) {
                var factor =
                    transactionData["risk_evaluation"]["risk_factors"][index];
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "• Factor: ${factor["factor"]}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text("  - Description: ${factor["description"]}"),
                    pw.Text("  - Impact: ${factor["risk_impact"]}"),
                    pw.SizedBox(height: 5),
                  ],
                );
              },
            ),
            pw.SizedBox(height: 10),

            // Transaction Details
            pw.Text(
              "Transaction Details:",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            ...transactionData["transaction_details"]["transaction_data"]
                .entries
                .map((entry) {
                  return pw.Text(
                    "${entry.key}: ${entry.value}",
                    style: pw.TextStyle(fontSize: 14),
                  );
                })
                .toList(),
          ],
        );
      },
    ),
  );

  // Save PDF
  final outputDir = await getTemporaryDirectory();
  final file = File("${outputDir.path}/fraud_transaction_report.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open PDF
  await OpenFile.open(file.path);
}
