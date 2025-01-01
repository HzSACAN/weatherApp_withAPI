import 'package:flutter/material.dart';

class WeatherInfoItem extends StatelessWidget {
  final String iconPath; // İkonun dosya yolu
  final String value; // Gösterilecek değer (örneğin sıcaklık)
  final String label; // Gösterilecek açıklama (örneğin "Rüzgar Hızı")

  const WeatherInfoItem({
    Key? key,
    required this.iconPath,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          iconPath,
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
