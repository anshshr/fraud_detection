import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generatePdf(Map<String, String> pdfData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title
          pw.Text(
            "Crop Report",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),

          // Crop Name
          pw.Text(
            "Crop Name: ${pdfData['crop_name'] ?? 'N/A'}",
            style: pw.TextStyle(fontSize: 18),
          ),
          pw.SizedBox(height: 10),

          // Gemini Response
          pw.Text("Gemini Extracted Text:", style: pw.TextStyle(fontSize: 18)),
          pw.Text(
            pdfData['gemini_response'] ?? 'No response',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 20),

          // Soil Parameters
          pw.Text("Soil Parameters:", style: pw.TextStyle(fontSize: 18)),
          pw.Bullet(
            text: "Phosphorus: ${pdfData['phosphorus'] ?? 'N/A'}",
          ),
          pw.Bullet(
            text: "Nitrogen: ${pdfData['nitrogen'] ?? 'N/A'}",
          ),
          pw.Bullet(
            text: "Humidity: ${pdfData['humidity'] ?? 'N/A'}",
          ),
          pw.Bullet(
            text: "Rainfall: ${pdfData['rainfall'] ?? 'N/A'}",
          ),
          pw.Bullet(
            text: "Soil Percentage: ${pdfData['soil_percentage'] ?? 'N/A'}",
          ),
          pw.SizedBox(height: 20),

          // Images Section
          pw.Text("Images:", style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 10),

          // Loop through images
          for (int i = 0; pdfData.containsKey('image_$i'); i++)
            pw.Column(children: [
              pw.Text("Image ${i + 1}:"),
              pw.SizedBox(height: 5),
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Image(
                  pw.MemoryImage(
                    File(pdfData['image_$i']!).readAsBytesSync(),
                  ),
                  width: 200,
                  height: 200,
                  fit: pw.BoxFit.cover,
                ),
              ),
            ]),
        ],
      ),
    ),
  );

  // Save PDF
  final outputDir = await getTemporaryDirectory();
  final file = File("${outputDir.path}/crop_report.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open PDF
  await OpenFile.open(file.path);
}
