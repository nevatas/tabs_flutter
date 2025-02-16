import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final _dateFormat = DateFormat('HH:mm');

  MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.getSecondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getDividedColor(context),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Text(
                message.text,
                style: TextStyle(
                  color: AppColors.getPrimaryText(context),
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                _dateFormat.format(message.timestamp),
                style: TextStyle(
                  color: AppColors.getSecondaryText(context),
                  fontSize: 12,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
