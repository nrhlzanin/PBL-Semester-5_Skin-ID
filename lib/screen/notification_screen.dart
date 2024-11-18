import 'package:flutter/material.dart';
import 'package:skin_id/button/bottom_navigation.dart';
import 'package:skin_id/button/navbar.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // List of dummy notifications to display on the screen
  final List<Map<String, String>> notifications = [
    {
      'title': 'Dermina just add new product you might interested',
      'subtitle': '',
      'time': '',
    },
    {
      'title': 'Herniawan liked your video',
      'subtitle': '',
      'time': '',
    },
    {
      'title': 'ZealinaaA liked your video',
      'subtitle': '',
      'time': '',
    },
    {
      'title': 'Thoriq_123 followed you',
      'subtitle': '',
      'time': '',
    },
  ];

  int _currentIndex = 1;

  // Handle tab tap to change screen
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, 
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Notification
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  Text(
                    'Notification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Add search functionality here
                    },
                  ),
                ],
              ),
            ),

            // List of Notifications
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (notification['subtitle']!.isNotEmpty)
                                SizedBox(height: 5),
                              if (notification['subtitle']!.isNotEmpty)
                                Text(
                                  notification['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (notification['time']!.isNotEmpty)
                                SizedBox(height: 5),
                              if (notification['time']!.isNotEmpty)
                                Text(
                                  notification['time']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
