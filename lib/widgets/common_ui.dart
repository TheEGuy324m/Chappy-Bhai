import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildHeader({
  required BuildContext context,
  required GlobalKey<ScaffoldState> scaffoldKey,
  required double screenWidth,
}) {
  final isMobile = screenWidth < 700;

  return Container(
    padding: EdgeInsets.fromLTRB(20, 35, 20, 15),
    color: Colors.grey[300],
    child: Row(
      children: [
        CircleAvatar(
          radius: isMobile ? 20 : 25,
          backgroundColor: Colors.grey[400],
          child: Text("Logo"),
        ),
        Spacer(),
        if (!isMobile)
          Row(
            children: [
              navItem(context, "Home", '/'),
              navItem(context, "Features", '/features'),
              navItem(context, "Cheffy", '/chappy'),
              navItem(context, "Grocery", '/grocery'),
              navItem(context, "Cookbook ❤️", '/favorites'),
            ],
          ),
        if (isMobile)
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
      ],
    ),
  );
}

Widget navItem(BuildContext context, String text, String route) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(text, style: TextStyle(fontSize: 16)),
    ),
  );
}

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: DrawerContent(),
  );
}

class DrawerContent extends StatefulWidget {
  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  String? userName;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');

    if (name == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _askNameDialog();
      });
    } else {
      setState(() {
        userName = name;
      });
    }
  }

  Future<void> _askNameDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Welcome 👋"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter your name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_name', controller.text);

                setState(() {
                  userName = controller.text;
                });

                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 TOP SECTION (ONLY TOP PADDING CHANGED HERE)
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, bottom: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[400],
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                userName == null ? "" : "Hello, $userName",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // MENU ITEMS
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              drawerItem(context, "Home", '/'),
              drawerItem(context, "Features", '/features'),
              drawerItem(context, "Chappy AI", '/chappy'),
              drawerItem(context, "Grocery", '/grocery'),
              drawerItem(context, "Cookbook ❤️", '/favorites'),
            ],
          ),
        ),

        // SETTINGS
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            children: [
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget drawerItem(BuildContext context, String text, String route) {
    return ListTile(
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}

Widget buildFooter() {
  return Container(
    width: double.infinity,
    color: Colors.grey[400],
    padding: EdgeInsets.all(30),
    child: Center(child: Text("Footer Section")),
  );
}