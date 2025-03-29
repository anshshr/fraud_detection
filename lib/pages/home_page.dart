import 'package:flutter/material.dart';
import 'package:fraud_detection/pages/multilingual_chat_bot/pages/record_audio.dart';
import 'package:fraud_detection/services/percnetage_pie_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PercentagePieChart(percentage: 20),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordAudio()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    width: 70,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
