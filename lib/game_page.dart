import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final WebViewController controller;
  final TextEditingController ipController = TextEditingController();
  String url = "http://192.168.0.8:3001"; // Update this if using an emulator
  bool showInput = false;

  @override
  void initState() {
    super.initState();
    // Ensure that the WebViewController is created
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          return NavigationDecision.navigate;
        },
      ));

    // Initialize the WebView
    _checkUrlAndLoad();
  }

  Future<void> _checkUrlAndLoad() async {
    bool reachable = await _isUrlReachable(Uri.parse(url));
    if (reachable) {
      controller.loadRequest(Uri.parse(url));
    } else {
      // Show input if the URL is not reachable
      setState(() {
        showInput = true;
      });
    }
  }

  Future<bool> _isUrlReachable(Uri url) async {
    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _loadCustomUrl() {
    final enteredUrl = ipController.text.trim();
    if (enteredUrl.isNotEmpty) {
      setState(() {
        url = enteredUrl;
        showInput = false;
        controller.loadRequest(Uri.parse(url));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showInput
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ipController,
                          decoration: InputDecoration(
                            labelText: "Enter IP Address",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _loadCustomUrl,
                        child: Text("Go"),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : WebViewWidget(controller: controller),
    );
  }
}
