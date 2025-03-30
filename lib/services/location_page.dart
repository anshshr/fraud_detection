import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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