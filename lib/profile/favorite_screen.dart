import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favoritePosts;

  FavoritesScreen({Key? key, required this.favoritePosts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Posts'),
      ),
      body: favoritePosts.isEmpty
          ? Center(
              child: Text('No favorites yet.'),
            )
          : ListView.builder(
              itemCount: favoritePosts.length,
              itemBuilder: (context, index) {
                final post = favoritePosts[index];
                return ListTile(
                  title: Text(post),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Remove from favorites and navigate back
                      Navigator.pop(context, post);
                    },
                  ),
                );
              },
            ),
    );
  }
}
