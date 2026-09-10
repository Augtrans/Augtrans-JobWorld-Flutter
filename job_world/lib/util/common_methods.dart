import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'dimensions.dart';

class CommonMethods {

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormatter = DateFormat('hh:mm a');

  // Method to extract clean API validation error messages (e.g. {"job": ["This field is required."]})
  static String extractErrorMessage(dynamic error) {
    if (error == null) return "An unexpected error occurred.";

    dynamic responseData;

    try {
      final dynamic dyn = error;
      if (dyn.data != null) {
        responseData = dyn.data;
      } else if (dyn.response != null && dyn.response.data != null) {
        responseData = dyn.response.data;
      }
    } catch (_) {}

    if (responseData != null) {
      if (responseData is Map<String, dynamic>) {
        List<String> messages = [];
        responseData.forEach((key, value) {
          String valStr = "";
          if (value is List) {
            valStr = value.map((e) => e.toString()).join(", ");
          } else if (value != null) {
            valStr = value.toString();
          }
          if (valStr.isNotEmpty) {
            if (key != 'detail' && key != 'message' && key != 'error' && key != 'non_field_errors') {
              final formattedKey = key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
              messages.add("$formattedKey: $valStr");
            } else {
              messages.add(valStr);
            }
          }
        });
        if (messages.isNotEmpty) {
          return messages.join("\n");
        }
      } else if (responseData is List && responseData.isNotEmpty) {
        return responseData.map((e) => e.toString()).join("\n");
      } else if (responseData is String && responseData.isNotEmpty) {
        return responseData;
      }
    }

    try {
      final dynamic dyn = error;
      if (dyn.message != null && dyn.message.toString().isNotEmpty && !dyn.message.toString().startsWith("Server error:")) {
        return dyn.message.toString();
      }
    } catch (_) {}

    final errStr = error.toString();
    if (errStr.contains("ApiException") || errStr.contains("Exception:")) {
      return errStr.replaceAll("ApiException(message: ", "").replaceAll(")", "").replaceAll("Exception: ", "");
    }

    return errStr;
  }

  // Method to show SnackBar (Toast style)
  static void showSnackBar(BuildContext context,
      String message, {
        Color? backgroundColor,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? Colors.grey[800] : Colors.black87),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimensions.mediumTextSize(context),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        bottom: 50,
        left: 20,
        right: 20,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String printLog(String input) {
    if (Constants.IS_LOG) {
      print(input);
      return input;
    } else {
      return "";
    }
  }

  static String convertDate(String? date1, String? inputFormatPattern,
      String? outputFormatPattern) {
    print("date1:$date1");
    print("inputFormatPattern:$inputFormatPattern");
    print("outputFormatPattern:$outputFormatPattern");

    if (date1 == null || inputFormatPattern == null ||
        outputFormatPattern == null) {
      return "";
    }

    try {
      DateTime parsedDate = DateFormat(inputFormatPattern).parse(date1);
      String formattedDate = DateFormat(outputFormatPattern).format(parsedDate);
      print(formattedDate);
      return formattedDate;
    } catch (e) {
      print("Date conversion error: $e");
      return ""; // Return empty string if parsing fails
    }
  }

  static Future<Map<String, String>> getFullLocation(double latitude,
      double longitude) async {
    List<Placemark> placemarks =
    await Geocoding().placemarkFromCoordinates(latitude, longitude);

    Placemark place = placemarks.first;

    String street = place.street ?? "";
    String area = place.subLocality ?? "";
    String city = place.locality ?? "";
    String district = place.subAdministrativeArea ?? "";
    String state = place.administrativeArea ?? "";
    String country = place.country ?? "";

    String fullAddress = "$street, $area, $city, $district, $state, $country";

    return {
      "street": street,
      "area": area,
      "city": city,
      "district": district,
      "state": state,
      "country": country,
      "fullAddress": fullAddress,
    };
  }

  static Future<Map<String, String>> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return {};
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      return {
        "city": place.locality ?? "",
        "area": place.subLocality ?? place.name ?? "",
        "fullAddress":
        "${place.street}, ${place.subLocality}, ${place.locality}",
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
      };
    } catch (e) {
      print("Location Error: $e");
      return {};
    }
  }

  static Future<void> getCityFromLatLong(double lat, double lon) async {
    List<Placemark> placemarks =
    await Geocoding().placemarkFromCoordinates(lat, lon);
    
    Placemark place = placemarks[0];

    print("City: ${place.locality}");
    print("Area: ${place.subLocality}");
    print("State: ${place.administrativeArea}");
    print("Country: ${place.country}");
  }

  static String formatDate(String dateString) {
    if (dateString
        .trim()
        .isEmpty) {
      return '';
    }
    try {
      // Try parsing full ISO datetime
      DateTime dateTime = DateTime.parse(dateString);
      return _dateFormatter.format(dateTime);
    } catch (e) {

      try {
        // Try parsing only date (yyyy-MM-dd)
        DateTime dateTime = DateFormat('yyyy-MM-dd').parse(dateString);
        return _dateFormatter.format(dateTime);
      } catch (e2) {
        return dateString; // fallback: return original
      }
    }
  }

  static String formatTime(String timeString) {
    if (timeString
        .trim()
        .isEmpty) {
      return '';
    }
    try {
      DateTime dateTime = DateFormat('HH:mm:ss').parse(timeString);
      return _timeFormatter.format(dateTime);
    } catch (e) {
      try {
        DateTime dateTime = DateFormat('HH:mm').parse(timeString);
        return _timeFormatter.format(dateTime);
      } catch (e2) {
        return timeString; // fallback
      }
    }
  }
}
