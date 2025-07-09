import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {},
        ),
        title: Text('X', style: TextStyle(color: Colors.white, fontSize: 24)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.group, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),


      body: Column(
        children: [
          Divider(color: Colors.grey, thickness: 1.5),
          // Top Tab Section with Home and Explore
          Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Home', style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Explore', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey, thickness: 1.5),
          // Discover New Communities Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Discover new Communities",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildGroupTile(
                  context,
                  'https://example.com/eFootball.png', // Replace with actual image URL
                  'eFootball 2024 Club',
                  '15.9K Members',
                ),
                _buildGroupTile(
                  context,
                  'https://example.com/XCommunities.png', // Replace with actual image URL
                  'X Communities Feedback',
                  '234K Members\nX Official',
                ),
                _buildGroupTile(
                  context,
                  'https://example.com/Supercharger.png', // Replace with actual image URL
                  'Supercharger (Official)',
                  '4,542 Members\nTechnology',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "Show more",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, String imageUrl, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
