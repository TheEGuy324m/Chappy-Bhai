import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsPage({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  String? userName;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      selectedLanguage = prefs.getString('language') ?? 'English';
      userName = prefs.getString('user_name') ?? 'Chef';
    });
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => isDarkMode = value);
    widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() => notificationsEnabled = value);
  }

  Future<void> clearFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear Cookbook?'),
        content: Text('This will remove all your saved recipes. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorites');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cookbook cleared!')),
      );
    }
  }

  Future<void> editName() async {
    final controller = TextEditingController(text: userName);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', controller.text);
              setState(() => userName = controller.text);
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = Colors.orange,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade50,
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12))
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [

          // ── PROFILE ─────────────────────────────────
          buildSectionTitle('PROFILE'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: buildTile(
              icon: Icons.person_outline,
              title: 'Your Name',
              subtitle: userName ?? 'Chef',
              trailing: Icon(Icons.edit, color: Colors.grey, size: 18),
              onTap: editName,
            ),
          ),

          // ── APPEARANCE ──────────────────────────────
          buildSectionTitle('APPEARANCE'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: buildTile(
              icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'Dark theme is on' : 'Light theme is on',
              trailing: Switch(
                value: isDarkMode,
                onChanged: toggleDarkMode,
                activeColor: Colors.orange,
              ),
            ),
          ),

          // ── PREFERENCES ─────────────────────────────
          buildSectionTitle('PREFERENCES'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                buildTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: notificationsEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: toggleNotifications,
                    activeColor: Colors.orange,
                  ),
                ),
                Divider(height: 1, indent: 16),
                buildTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: selectedLanguage,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 12),
                          Text(
                            'Select Language',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...['English', 'Urdu', 'Arabic', 'French', 'Spanish']
                              .map(
                                (lang) => ListTile(
                                  title: Text(lang),
                                  trailing: selectedLanguage == lang
                                      ? Icon(Icons.check, color: Colors.orange)
                                      : null,
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('language', lang);
                                    setState(() => selectedLanguage = lang);
                                    Navigator.pop(context);
                                  },
                                ),
                              )
                              .toList(),
                          SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── DATA ────────────────────────────────────
          buildSectionTitle('DATA'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: buildTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear Cookbook',
              subtitle: 'Remove all saved recipes',
              iconColor: Colors.red,
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: clearFavorites,
            ),
          ),

          // ── ABOUT ───────────────────────────────────
          buildSectionTitle('ABOUT'),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                buildTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  trailing: SizedBox.shrink(),
                ),
                Divider(height: 1, indent: 16),
                buildTile(
                  icon: Icons.restaurant,
                  title: 'About Cheffy',
                  subtitle: 'Your AI cooking assistant ❤️',
                  trailing: SizedBox.shrink(),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}