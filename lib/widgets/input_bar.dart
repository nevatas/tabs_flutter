import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed;
  final String hintText;

  const InputBar({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onAttachPressed,
    this.hintText = 'Введите сообщение...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 10,
            color: Colors.black.withAlpha(26),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: onAttachPressed,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSendPressed(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}
