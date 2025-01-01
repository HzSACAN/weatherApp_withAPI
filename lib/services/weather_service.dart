import 'dart:convert';
import 'package:flutter/services.dart'; // To read local JSON file
import 'package:http/http.dart' as http;



class WeatherService {
  final String apiKey = "fb6d79f1ed7fc67ec256b1d55bb37df6"; // API anahtarınızı buraya koyun.
  final String apiUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<void> fetchWeatherData(String cityName) async {
    try {
      // JSON dosyasını okuyun
      final String response = await rootBundle.loadString('assets/city_list.json');
      final List<dynamic> cityList = json.decode(response);

      // Şehir adını arayın ve id'sini bulun
      final city = cityList.firstWhere(
            (element) => element['name'].toString().toLowerCase() == cityName.toLowerCase(),
        orElse: () => null,
      );

      if (city != null) {
        final int cityId = city['id']; // Şehir id'sini alın
        print("City ID: $cityId");

        // API çağrısını yapın
        final url = Uri.parse("$apiUrl?id=$cityId&appid=$apiKey&units=metric");
        final http.Response weatherResponse = await http.get(url);

        if (weatherResponse.statusCode == 200) {
          final weatherData = json.decode(weatherResponse.body);
          print("Weather Data: $weatherData");
          // Burada gelen hava durumu bilgilerini işleyebilirsiniz
        } else {
          print("Error: ${weatherResponse.statusCode}");
        }
      } else {
        print("City not found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
