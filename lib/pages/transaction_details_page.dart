import 'package:flutter/material.dart';
import 'package:fraud_detection/services/create_pdf.dart';
import 'package:fraud_detection/services/percnetage_pie_chart.dart';
import 'package:fraud_detection/widgets/custom_appbar.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const TransactionDetailsPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    var riskEvaluation =
        transactionData["risk_evaluation"] as Map<String, dynamic>? ?? {};
    var riskFactors = riskEvaluation["risk_factors"] as List<dynamic>? ?? [];
    var transactionDetails =
        transactionData["transaction_details"]?["transaction_data"]
            as Map<String, dynamic>? ??
        {};

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Report Summary:", style: sectionTitleStyle),
            Text(
              transactionData["report_summary"] ?? "N/A",
              style: contentStyle,
            ),
            const SizedBox(height: 10),

            Text("Overall Risk Score:", style: sectionTitleStyle),
            Text(
              riskEvaluation["overall_risk_score"]?.toString() ?? "N/A",
              style: contentStyle,
            ),
            const Divider(),

            Text("Transaction Details", style: sectionTitleStyle),
            infoTile("Transaction Type", transactionDetails["type"]),
            infoTile(
              "Transfer Amount",
              "${transactionDetails["transfer_amount"] ?? 'N/A'} /-",
            ),
            infoTile("Card Type", transactionDetails["card_type"]),
            infoTile(
              "Transaction Hour",
              transactionDetails["transaction_hour"],
            ),
            infoTile(
              "Bank Operational Hours",
              transactionDetails["bank_operational_hours"],
            ),
            infoTile(
              "Device Usage Pattern",
              transactionDetails["device_usage_pattern"],
            ),
            infoTile("Channel Used", transactionDetails["channel_used"]),
            infoTile(
              "User Behavior",
              transactionDetails["user_behavior_description"],
            ),

            const Divider(),
            Text("Risk Factors", style: sectionTitleStyle),
            riskFactors.isEmpty
                ? const Text("No risk factors identified.", style: contentStyle)
                : Column(
                  children:
                      riskFactors.map((factor) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              "Factor: ${factor["factor"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Impact: ${factor["risk_impact"]}\n${factor["description"]}",
                            ),
                          ),
                        );
                      }).toList(),
                ),
            const Divider(),
            SizedBox(
              height: 200,
              child: PercentagePieChart(
                percentage: double.parse(
                  riskEvaluation["overall_risk_score"].toString(),
                ),
              ),
            ),

            my_button(
              text: "Generate the Detailed Report",
              ontap: () {
                generateFraudTransactionPdf(transactionData);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text("$title:", style: sectionTitleStyle)),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: contentStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Styling for the text
const TextStyle sectionTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
const TextStyle contentStyle = TextStyle(fontSize: 14);
