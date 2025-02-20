import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';

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
      home: const ChatScreen(),
    );
  }
}

void main() {
  runApp(const MessengerApp());
}
