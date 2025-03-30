import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fraud_detection/services/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Import Lottie package

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

  Future<Map<String, String>> getCityAndCountry() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {"error": "Location services disabled"};
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return {"error": "Permission denied"};
        }
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Reverse geocoding to get placemark
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String city = placemarks.first.locality ?? "City not found";
      String country = placemarks.first.country ?? "Country not found";

      // Save city and country to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("city", city);
      await prefs.setString("country", country);

      return {"city": city, "country": country};
    } catch (e) {
      print(e.toString());
      return {"error": "Error: ${e.toString()}"};
    }
  }

  Future<void> fetchThreats() async {
    setState(() {
      isLoading = true;
    });

    final locationData = await getCityAndCountry();

    if (locationData.containsKey("error")) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationData["error"]!)));
      return;
    }

    final String city = locationData["city"] ?? "Unknown";

    const url = 'https://codespaces-express-3.onrender.com/detect-threats';
    final body = {"location": city};

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            isLoading
                ? Center(
                  child: Lottie.asset(
                    'assets/json/a1.json',
                    width: 200,
                    height: 200,
                  ),
                )
                : threats.isEmpty
                ? const Center(
                  child: Text(
                    'No threats found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
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
                            colors: [Colors.green.shade600, Colors.black87],
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
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                threat['description'] ?? 'No Description',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
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
                                  child: const Text(
                                    'Read More',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
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
      ),
    );
  }
}
