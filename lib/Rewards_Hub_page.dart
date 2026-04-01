import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cheffy/widgets/common_ui.dart';

class RewardsHubPage extends StatefulWidget {
  @override
  _RewardsHubPageState createState() => _RewardsHubPageState();
}

class _RewardsHubPageState extends State<RewardsHubPage> {
  List<Map<String, dynamic>> rewards = [];
  int userPoints = 0;
  final ImagePicker picker = ImagePicker();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  Future<void> loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPoints = prefs.getInt('userPoints') ?? 0;

      rewards = [
        {"title": "Pasta Carbonara", "image": null, "status": "Pending", "points": 0},
        {"title": "Chocolate Cake", "image": null, "status": "Pending", "points": 0},
        {"title": "Vegan Salad", "image": null, "status": "Pending", "points": 0},
      ];
    });
  }

  Future<bool> requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus galleryStatus = await Permission.photos.request();

    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permissions denied. Enable from settings.")),
      );
      return false;
    }
  }

  Future<void> pickImage(int index) async {
    bool hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int pointsEarned = evaluateImage(imageFile);

      setState(() {
        rewards[index]['image'] = imageFile;
        rewards[index]['status'] = "Verified";
        rewards[index]['points'] = pointsEarned;
        userPoints += pointsEarned;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userPoints', userPoints);
    }
  }

  int evaluateImage(File image) {
    return 10 + (image.path.hashCode % 41);
  }

  Widget buildRewardCard(int index) {
    final reward = rewards[index];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              reward['title'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            reward['image'] != null
                ? Image.file(reward['image'], height: 120)
                : Icon(Icons.image, size: 100, color: Colors.grey),

            SizedBox(height: 10),

            Text("Status: ${reward['status']}"),
            Text("Points: ${reward['points']}"),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => pickImage(index),
              child: Text(
                reward['status'] == "Pending"
                    ? "Upload Image"
                    : "Re-upload",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrizes() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text("🎁 Prizes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("100 pts → Utensil\n250 pts → Recipe Book\n500 pts → Mystery Box"),
          SizedBox(height: 10),

          LinearProgressIndicator(
            value: (userPoints % 500) / 500,
            minHeight: 10,
          ),

          SizedBox(height: 5),
          Text("Your Points: $userPoints"),
        ],
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
          /// HEADER
          buildHeader(
            context: context,
            scaffoldKey: _scaffoldKey,
            screenWidth: screenWidth,
          ),

          /// MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPrizes(),
                  SizedBox(height: 20),

                  Text(
                    "Your Recipes:",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  ...List.generate(
                      rewards.length, (index) => buildRewardCard(index)),
                ],
              ),
            ),
          ),

          /// FOOTER
          buildFooter(),
        ],
      ),
    );
  }
}