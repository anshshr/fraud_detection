import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fraud_detection/services/url_launcher.dart';
import 'package:http/http.dart' as http;

class DataInsightsPage extends StatefulWidget {
  const DataInsightsPage({super.key});

  @override
  State<DataInsightsPage> createState() => _DataInsightsPageState();
}

class _DataInsightsPageState extends State<DataInsightsPage> {
  List<dynamic> threats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchThreats();
  }

  Future<void> fetchThreats() async {
    const url = 'https://codespaces-express-3.onrender.com/detect-threats';
    const body = {"location": "surat"};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          threats = data['threats'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load threats');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : threats.isEmpty
              ? const Center(child: Text('No threats found'))
              : ListView.builder(
                itemCount: threats.length,
                itemBuilder: (context, index) {
                  final threat = threats[index];
                  return Card(
                    margin: const EdgeInsets.all(12.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              threat['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              threat['description'] ?? 'No Description',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () async {
                                  final url =
                                      threat['safe_url'] ?? threat['url'];
                                  if (url != null) {
                                    print(url);
                                    await launchURL(url);
                                  }
                                },
                                child: Text(
                                  'Read More',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
