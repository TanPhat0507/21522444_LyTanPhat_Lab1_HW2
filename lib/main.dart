import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(SentimentApp());
}

class SentimentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SentimentScreen(),
    );
  }
}

class SentimentScreen extends StatefulWidget {
  @override
  _SentimentScreenState createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final TextEditingController _controller = TextEditingController();
  Color backgroundColor = Colors.grey[200]!;
  String imagePath = 'assets/neutral.png';

  static const String _apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
  static const String _apiKey = "AIzaSyBnSlrt13553n0Y4GB1HvIxmTkapIxcEzw";

  Future<void> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse("$_apiUrl?key=$_apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [{"parts": [{"text": "Hãy phân tích cảm xúc của câu này: '$text'. Đáp án chỉ là 'positive', 'negative' hoặc 'neutral'."}]}]
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String sentiment = data["candidates"][0]["content"]["parts"][0]["text"].toLowerCase();

      setState(() {
        if (sentiment.contains("positive")) {
          backgroundColor = Colors.green;
          imagePath = 'assets/happy.png';
        } else if (sentiment.contains("negative")) {
          backgroundColor = Colors.red;
          imagePath = 'assets/sad.png';
        } else {
          backgroundColor = Colors.grey;
          imagePath = 'assets/neutral.png';
        }
      });
    } else {
      print("Lỗi khi gọi API: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: Text("Sentiment analysis")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nhập câu của bạn",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => analyzeSentiment(_controller.text),
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
              Image.asset(imagePath, width: 100, height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
