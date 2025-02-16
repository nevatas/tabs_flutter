import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../theme/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Function(MessageCategory)? onMove;
  final VoidCallback? onDelete;
  final _dateFormat = DateFormat('HH:mm');

  MessageBubble({
    super.key,
    required this.message,
    this.onMove,
    this.onDelete,
  });

  void _showMoveDialog(BuildContext context) {
    final categories =
        MessageCategory.values.where((cat) => cat != message.category).toList();

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text(
            'Переместить в',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          actions: categories.map((category) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                onMove?.call(category);
              },
              child: Text(category.name),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Переместить в',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ...categories.map((category) {
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    Navigator.pop(context);
                    onMove?.call(category);
                  },
                );
              }),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onMove != null ? () => _showMoveDialog(context) : null,
      child: Container(
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
      ),
    );
  }
}
