import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:projects/models/constants.dart';
import 'package:projects/ui/weather_info_item.dart';

class Home extends StatefulWidget {
  final List<String> selectedCities;

  const Home({Key? key, required this.selectedCities}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants myConstants = Constants();

  // Initialization
  double temperature = 0;
  double maxTemp = 0;
  String weatherStateName = 'Loading..';
  int humidity = 0;
  double windSpeed = 0;

  var currentDate = 'Loading..';
  String location = 'London'; // Default city

  List<String> cities = ['London']; // Default city list

  final String apiKey = "api_key";
  final String apiUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<void> fetchWeatherData(String cityName) async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/city.list.json');
      final List<dynamic> cityList = json.decode(jsonString);

      final city = cityList.firstWhere(
            (element) =>
        element['name'].toString().toLowerCase() == cityName.toLowerCase(),
        orElse: () => null,
      );

      if (city == null) {
        print("Hata: Şehir '$cityName' bulunamadı.");
        return;
      }

      final int cityId = city['id'];
      print("Şehir ID'si: $cityId");

      final Uri url = Uri.parse(
          "$apiUrl?id=$cityId&appid=$apiKey&units=metric");

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> weatherData = json.decode(response.body);

        setState(() {
          temperature = weatherData['main']['temp'];
          maxTemp = weatherData['main']['temp_max'];
          weatherStateName = weatherData['weather'][0]['main'];
          humidity = weatherData['main']['humidity'];
          windSpeed = weatherData['wind']['speed'];
          currentDate = DateFormat('EEEE, d MMMM').format(DateTime.now());
        });
      } else {
        print("API Hatası: ${response.statusCode}");
        print("Hata Mesajı: ${response.body}");
      }
    } catch (e) {
      print("Bir hata oluştu: $e");
    }
  }

  String _getWeatherIcon(String weatherStateName) {
    switch (weatherStateName) {
      case 'Clear':
        return 'assets/clear.png';
      case 'Clouds':
        return 'assets/heavycloud.png';
      case 'Snow':
        return 'assets/snow.png';
      case 'Rain':
        return 'assets/hail.png';
      case 'Drizzle':
        return 'assets/lightrain.png';
      case 'Thunderstorm':
        return 'assets/thunderstorm-.png';
      default:
        return 'assets/mist.png';
    }
  }

  @override
  void initState() {
    super.initState();

    cities = widget.selectedCities.toSet().toList();

    if (!cities.contains(location)) {
      location = cities.isNotEmpty ? cities[0] : 'London';
    }

    fetchWeatherData(location);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pin.png',
                    width: 20,
                  ),
                  const SizedBox(width: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: location,
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          location = newValue!;
                          fetchWeatherData(location);
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              Text(
                currentDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: myConstants.primaryColor.withOpacity(.5),
                      offset: const Offset(0, 25),
                      blurRadius: 10,
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Image.asset(
                        _getWeatherIcon(weatherStateName),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // weatherStateName'i ekliyoruz
                    Positioned(
                      bottom: 30  ,
                      left: 25,
                      child: Text(
                        weatherStateName, // Hava durumu bilgisi
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontStyle: FontStyle.italic, // Yazıyı italik yapmak için
                          letterSpacing: 2.0, // Harfler arası boşluk
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0), // Gölgenin konumu
                              blurRadius: 4.0, // Gölge bulanıklığı
                              color: Colors.black, // Gölge rengi
                            ),
                          ],
                          fontFamily: 'Roboto', // Yazı tipi (font)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/windspeed-.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${windSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Wind Speed',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/humidity.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$humidity%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Humidity',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/maxtemp.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${maxTemp.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Max Temp',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
