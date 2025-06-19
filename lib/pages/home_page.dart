import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fraud_detection/pages/auth/services/auth_service.dart';
import 'package:fraud_detection/pages/transaction_details_page.dart';
import 'package:fraud_detection/widgets/card_payment.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _authService.getCurrentUserId();
  }

  Color getCardColor(double riskScore) {
    if (riskScore <= 40) {
      return Colors.lightGreen.shade100;
    } else if (riskScore <= 80) {
      return Colors.yellow.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 5,
            right: 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CardPayment()),
                    );
                  },
                  child: const Text("Make a Payment"),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Transaction Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child:
                _userId == null
                    ? _buildNotLoggedInUI()
                    : StreamBuilder<QuerySnapshot>(
                      stream:
                          _firestore
                              .collection('users')
                              .doc(_userId)
                              .collection('transactions')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Lottie.asset(
                              'assets/json/a2.json',
                              width: 200,
                              height: 200,
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _buildEmptyTransactionsUI();
                        }
                        return _buildTransactionsList(snapshot.data!.docs);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/json/a2.json', width: 200, height: 200),
          const Text(
            "Please sign in to view your transactions",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionsUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/json/a2.json', width: 200, height: 200),
          const Text("No transactions found", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CardPayment()),
              );
            },
            child: const Text("Make your first payment"),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var doc = docs[index];
        var transactionData = doc.data() as Map<String, dynamic>;

        // Extract transaction analysis data
        var analysisData =
            transactionData['transaction_analysis'] as Map<String, dynamic>? ??
            transactionData;

        var summary = analysisData["report_summary"] ?? "No summary available";
        var riskEvaluation =
            analysisData["risk_evaluation"] as Map<String, dynamic>? ?? {};
        var riskScore =
            double.tryParse(
              riskEvaluation["overall_risk_score"]?.toString() ?? "0",
            ) ??
            0.0;

        // Get the amount - checking multiple possible locations
        var amount = _getTransactionAmount(transactionData, analysisData);

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 3,
          color: getCardColor(riskScore),
          child: ListTile(
            title: Text(
              "Risk Score: ${riskScore.toStringAsFixed(1)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary),
                const SizedBox(height: 4),
                Text(
                  "Amount: \₹${amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (transactionData['formattedDate'] != null)
                  Text(
                    transactionData['formattedDate'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          TransactionDetailsPage(transactionData: analysisData),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _getTransactionAmount(
    Map<String, dynamic> transactionData,
    Map<String, dynamic> analysisData,
  ) {
    // Check multiple possible locations for the amount
    if (transactionData['amount'] != null) {
      return double.tryParse(transactionData['amount'].toString()) ?? 0.0;
    } else if (analysisData['amount'] != null) {
      return double.tryParse(analysisData['amount'].toString()) ?? 0.0;
    } else if (transactionData['paymentDetails'] != null &&
        transactionData['paymentDetails']['amount'] != null) {
      return double.tryParse(
            transactionData['paymentDetails']['amount'].toString(),
          ) ??
          0.0;
    }
    return 0.0;
  }
}
