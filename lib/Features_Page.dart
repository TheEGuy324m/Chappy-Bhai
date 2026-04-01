import 'package:flutter/material.dart';
import 'package:cheffy/widgets/common_ui.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final List<Map<String, String>> features = [
      {
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZuucasw_dmQZk7uZsMyoJymP_g_39dr0aInBdFnVSRKX0oUtl',
        'name': 'AI Chat Chef',
        'description':
            'Your personal AI assistant that summarizes videos, guides recipes, suggests ingredients, and chats with you while cooking.'
      },
      {
        'image':
            'https://cdn-icons-png.flaticon.com/512/5088/5088218.png',
        'name': 'Nearby Stores Map',
        'description':
            'Locate stores near you quickly with an interactive map and get directions if needed.'
      },
      {
        'image':
            'https://tse1.mm.bing.net/th/id/OIP.sjcUcqF6Bdai2O1uL5WdowHaH7?rs=1&pid=ImgDetMain&o=7&rm=3',
        'name': 'Online Grocery Integration',
        'description': 'Order ingredients directly online without stepping outside.'
      },
      {
        'image':
            'https://cdn-icons-png.flaticon.com/512/32/32223.png',
        'name': 'Recipe History & Analytics',
        'description':
            'Access past recipes anytime and visualize your cooking habits with charts.'
      },
      {
        'image':
            'https://cdn-icons-png.flaticon.com/256/10264/10264233.png',
        'name': 'Recipe Sharing',
        'description':
            'Share your favorite recipes with friends via social media, messaging, or email.'
      },
      {
        'image':
            'https://static.vecteezy.com/system/resources/thumbnails/029/884/056/small/notification-bell-icon-in-flat-style-incoming-inbox-message-illustration-on-isolated-background-ringing-bell-sign-business-concept-vector.jpg',
        'name': 'Smart Notifications & Favourite Recipes',
        'description':
            'Get real-time alerts and a receipt-style summary of your completed recipes.'
      },
      {
        'image':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjXFYsN261iE8y6TU9wYcJDKdEtSulAxwBcQ&s',
        'name': 'Photo Capture & Rewards',
        'description':
            'Take pictures of your dishes, earn points, and redeem them for prizes.'
      },
    ];

    return Scaffold(
      key: _scaffoldKey,

      /// ✅ COMMON DRAWER
      drawer: buildDrawer(context),

      body: Column(
        children: [
          /// ✅ COMMON HEADER
          buildHeader(
            context: context,
            scaffoldKey: _scaffoldKey,
            screenWidth: screenWidth,
          ),

          /// FEATURES LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  final bool isHero = feature['name'] == 'AI Chat Chef';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: isHero ? 8 : 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: isHero
                        ? Colors.deepOrangeAccent.withOpacity(0.1)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ IMAGE ON LEFT
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              feature['image']!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // ✅ NAME AND DESCRIPTION
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feature['name']!,
                                  style: TextStyle(
                                    fontSize: isHero ? 20 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  feature['description']!,
                                  style: TextStyle(
                                    fontSize: isHero ? 16 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// ✅ COMMON FOOTER
          buildFooter(),
        ],
      ),
    );
  }
}