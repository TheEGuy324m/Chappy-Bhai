import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheffy/widgets/common_ui.dart';

import 'Features_Page.dart';
import 'chappy_ai.dart';
import 'grocery_page.dart';
import 'favorites_page.dart';
import 'Rewards_Hub_Page.dart';
import 'settings_page.dart'; // ← new

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(initialTheme: isDark ? ThemeMode.dark : ThemeMode.light));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialTheme;
  const MyApp({Key? key, required this.initialTheme}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
  }

  void updateTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(onThemeChanged: updateTheme),
        '/features': (context) => FeaturesPage(),
        '/chappy': (context) => ChatPage(),
        '/grocery': (context) => GroceryPage(),
        '/favorites': (context) => FavoritesPage(),
        '/rewards': (context) => RewardsHubPage(),
        '/settings': (context) => SettingsPage(onThemeChanged: updateTheme), // ← new
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const HomePage({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedMood = "Comfort";
  String selectedTime = "20 min";
  String selectedDifficulty = "Easy";
  String selectedSpice = "Medium";
  String selectedPortion = "2";

  bool showCustomize = false;

  final List<String> sliderImages = [
    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ3MBjZ-4iLYyZTWsO1q4aqKg77a-zcmM1Npg&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1niPhizUz6SCoFsZsIAoVfRc9hDYC9hj19A&s=0',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt6zKlWn0zYSDXv2XwOIDGWfsfi1OVDWmAcw&s=0',
  ];

  int currentSliderIndex = 0;

  @override
  void initState() {
    super.initState();
    changeSlider();
  }

  void changeSlider() {
    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        currentSliderIndex = (currentSliderIndex + 1) % sliderImages.length;
      });
      changeSlider();
    });
  }

  Widget buildChips(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Wrap(
          spacing: 10,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selectedValue == option,
              onSelected: (_) {
                setState(() {
                  onSelected(option);
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget featureBox(double size, String imageUrl) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          width: size * 0.6,
          height: size * 0.6,
          fit: BoxFit.contain,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        sliderImages[currentSliderIndex],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        "Chappy\nYour personal chef",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://blogger.googleusercontent.com/img/a/AVvXsEiNLmzoF-3LHEYmVWmI5vdni65pl71m9nH75sj6lIhTQCz17isyMbGNAyKLUKM38XbjOGROBOlZtFcqiOKQRSEgwehboxYQJIBWILQ9wpH5xfQG0HJyYdSF3w1y6O98Cr7E10JD9_3LM0OVHvtqwdRHoYICslm27U9tvnIhvEgHYdtDFlaJ9pQYEajv6ZM',
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Cheffy AI helps you cook smarter with AI-powered recipes.",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Wrap(
                    spacing: 20,
                    children: [
                      featureBox(60, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRK-F7fOE0wj9WfuZxwfuf5DWyw-TxBWhdDEA&s'),
                      featureBox(60, 'https://cdn-icons-png.flaticon.com/512/1170/1170678.png'),
                      featureBox(60, 'https://cdn-icons-png.flaticon.com/512/684/684908.png'),
                      featureBox(60, 'https://cdn-icons-png.flaticon.com/512/2583/2583285.png'),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/chappy'),
                    child: Text("Open Cheffy"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/rewards'),
                    child: Text("Rewards Hub 🎁"),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          buildFooter(),
        ],
      ),
    );
  }
}