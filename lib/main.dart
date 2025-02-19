import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';
import 'widgets/side_menu.dart';
import 'models/tab_item.dart';

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme.copyWith(
                bodyLarge: const TextStyle(
                  fontSize: 17,
                  fontVariations: [
                    FontVariation('wght', 400),
                  ],
                ),
                bodyMedium: const TextStyle(
                  fontSize: 14,
                  fontVariations: [
                    FontVariation('wght', 400),
                  ],
                ),
              ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        tabs: TabItem.defaultTabs,
        selectedIndex: 0,
        onTabSelected: (index) {
          // Обработка выбора таба
        },
        onCreateTab: (title) {
          // Здесь можно оставить пустую реализацию, так как основная логика в ChatScreen
        },
      ),
      drawerEdgeDragWidth: 60, // Ширина области для свайпа
      body: const ChatScreen(),
    );
  }
}

void main() {
  runApp(const MessengerApp());
}
