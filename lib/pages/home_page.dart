import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fraud_detection/services/create_pdf.dart';
import 'package:fraud_detection/services/percnetage_pie_chart.dart';
import 'package:fraud_detection/widgets/card_payment.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20,
            right: 1
            ,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardPayment()),
                    );
                  },
                  child: Text("Make a dummy payment"),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      image: NetworkImage(
                        'https://www.shutterstock.com/image-illustration/3d-illustration-little-robot-fat-260nw-1640636815.jpg',
                      ),
                    ),
                    border: Border.all(width: 2, color: Colors.black87),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection("transactions_report").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions available"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var transactionData =
                  doc["transaction_analysis"] as Map<String, dynamic>? ?? {};
              var summary =
                  transactionData["report_summary"] ?? "No summary available";
              var riskEvaluation =
                  transactionData["risk_evaluation"] as Map<String, dynamic>? ??
                  {};
              var riskScore = riskEvaluation["overall_risk_score"] ?? "N/A";

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    "Risk Score: $riskScore",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(summary),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TransactionDetailsPage(
                              transactionData: transactionData,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: const Text("Transaction Details")),
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
              "\$${transactionDetails["transfer_amount"] ?? 'N/A'}",
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
              "Geographical Context",
              transactionDetails["geographical_context"],
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
                percentage: (riskEvaluation["overall_risk_score"] is int
                    ? riskEvaluation["overall_risk_score"].toDouble()
                    : double.parse(riskEvaluation["overall_risk_score"])),
              ),
            ),

            my_button(
              text: "Generated the Detailed Report",
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
