import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> removeFavorite(String item) async {
    final prefs = await SharedPreferences.getInstance();
    favorites.remove(item);
    await prefs.setStringList('favorites', favorites);
    setState(() {});
  }

  void showReceipt() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptSheet(
        favorites: favorites,
        date: dateStr,
        time: timeStr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cookbook ❤️"),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.receipt_long),
              tooltip: 'Make Receipt',
              onPressed: showReceipt,
            ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text(
                    "No saved recipes yet",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return AnimatedRecipeCard(
                  recipe: recipe,
                  index: index,
                  onDelete: () => removeFavorite(recipe),
                );
              },
            ),
    );
  }
}

class AnimatedRecipeCard extends StatefulWidget {
  final String recipe;
  final int index;
  final VoidCallback onDelete;

  const AnimatedRecipeCard({
    Key? key,
    required this.recipe,
    required this.index,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AnimatedRecipeCardState createState() => _AnimatedRecipeCardState();
}

class _AnimatedRecipeCardState extends State<AnimatedRecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    final delay = widget.index * 100;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });

    _rotationAnim = Tween<double>(begin: -0.4, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnim = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shareRecipe(String recipe) {
    Share.share(
      '🍽️ Check out this recipe from My Cookbook!\n\n$recipe\n\nShared via My Cookbook App ❤️',
      subject: 'Recipe: $recipe',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_rotationAnim.value),
              child: child,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.red[100],
            child: Icon(Icons.restaurant, color: Colors.red[400]),
          ),
          title: Text(
            widget.recipe,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.blue[400]),
                tooltip: 'Share recipe',
                onPressed: () => shareRecipe(widget.recipe),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                tooltip: 'Remove',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.recipe} removed'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  widget.onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptSheet extends StatelessWidget {
  final List<String> favorites;
  final String date;
  final String time;

  const ReceiptSheet({
    Key? key,
    required this.favorites,
    required this.date,
    required this.time,
  }) : super(key: key);

  void shareReceipt() {
    final recipeList = favorites
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    Share.share(
      '🧾 My Cookbook Receipt\n'
      '──────────────────\n'
      '$recipeList\n'
      '──────────────────\n'
      'Total: ${favorites.length} recipes\n'
      'Date: $date  Time: $time\n\n'
      'Shared via My Cookbook App ❤️',
      subject: 'My Cookbook Recipe List',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '🧾 My Cookbook',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Date: $date   Time: $time',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(height: 16),
          Divider(thickness: 1.5, color: Colors.grey[400]),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.restaurant_menu,
                          size: 16, color: Colors.red[300]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          favorites[index],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(thickness: 1.5, color: Colors.grey[400]),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Recipes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                '${favorites.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: shareReceipt,
              icon: Icon(Icons.share),
              label: Text('Share Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}