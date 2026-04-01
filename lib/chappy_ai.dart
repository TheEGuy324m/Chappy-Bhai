import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheffy/widgets/common_ui.dart';
import 'cooking_mode_page.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, String>> messages = [];
  List<String> currentSuggestions = [];
  String lastAIResponse = "";
  bool _isSaved = false; // ← new

  final List<String> allSuggestions = [
    "Let's make a sandwich 🥪",
    "Quick egg breakfast 🍳",
    "Healthy salad time 🥗",
    "Chocolate dessert 🍫",
    "Yummy pasta tonight 🍝",
    "Soup to warm you up 🍲",
    "Smoothie break 🥤",
    "Baking fun 🍪",
    "Vegan meal ideas 🌱",
    "Grilled dishes 🍖",
    "Snack attack 🍿",
    "Dinner in 20 mins ⏱️",
  ];

  Timer? suggestionTimer;

  @override
  void initState() {
    super.initState();
    updateSuggestions();
    suggestionTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      updateSuggestions();
    });
  }

  @override
  void dispose() {
    suggestionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> saveFavorite(String recipe) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    if (!favorites.contains(recipe)) {
      favorites.add(recipe);
      await prefs.setStringList('favorites', favorites);
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved to Cookbook ❤️")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already in your Cookbook!")),
      );
    }
  }

  void updateSuggestions() {
    setState(() {
      currentSuggestions = getRandomSuggestions(4);
    });
  }

  void sendMessage([String? customText]) {
    String text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      _isSaved = false; // reset heart on new message
    });

    _controller.clear();

    Future.delayed(Duration(milliseconds: 500), () {
      String reply = getReply(text);
      setState(() {
        lastAIResponse = reply;
        messages.add({"sender": "bot", "text": reply});
      });
    });
  }

  String getReply(String input) {
    input = input.toLowerCase();

    if (input.contains("hello")) {
      return "Hi! I'm Chappy, your cooking assistant!";
    } else if (input.contains("chicken")) {
      return "Step 1: Cut chicken\nStep 2: Fry onions\nStep 3: Add spices\nStep 4: Cook 10 min";
    } else if (input.contains("egg")) {
      return "Step 1: Beat eggs\nStep 2: Heat pan\nStep 3: Cook 5 min\nStep 4: Serve warm";
    } else {
      return "Step 1: Prepare ingredients\nStep 2: Cook properly\nStep 3: Serve and enjoy";
    }
  }

  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg["sender"] == "user";

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  List<String> getRandomSuggestions(int count) {
    final random = Random();
    List<String> copy = List.from(allSuggestions);
    copy.shuffle(random);
    return copy.take(count).toList();
  }

  Widget buildRecommendations() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: currentSuggestions.map((text) {
          return InkWell(
            onTap: () => sendMessage(text),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                text,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildChatBar() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Ask Chappy...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                color: lastAIResponse.isNotEmpty ? Colors.red : Colors.grey,
              ),
              tooltip: lastAIResponse.isNotEmpty
                  ? 'Save to Cookbook'
                  : 'Ask Chappy first',
              onPressed: lastAIResponse.isNotEmpty
                  ? () => saveFavorite(lastAIResponse)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.orange),
              onPressed: () => sendMessage(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: buildDrawer(context),
      body: Column(
        children: [
          buildHeader(
            context: context,
            scaffoldKey: _scaffoldKey,
            screenWidth: screenWidth,
          ),
          SizedBox(height: 4),
          Text(
            "Let's cook with Chappy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          buildChatBar(),
          SizedBox(height: 6),
          buildRecommendations(),
          SizedBox(height: 6),
          if (lastAIResponse.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                List<String> steps = lastAIResponse.split('\n');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CookingModePage(steps: steps),
                  ),
                );
              },
              child: Text("Start Cooking Mode 🍳"),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          buildFooter(),
        ],
      ),
    );
  }
}