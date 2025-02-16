import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../models/message.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  final VoidCallback onSendPressed;

  final VoidCallback onAttachPressed;

  final String hintText;

  final bool isSelectionMode;

  final int selectedCount;

  final VoidCallback onDelete;

  final Function(MessageCategory) onMove;

  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendPressed,
    required this.onAttachPressed,
    required this.hintText,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    required this.onDelete,
    required this.onMove,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  bool get isTextEmpty => widget.controller.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.getPrimaryBackground(context),
        child: Row(
          children: [
            Text(
              '${widget.selectedCount} выбрано',
              style: TextStyle(
                color: AppColors.getPrimaryText(context),
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.drive_file_move),
              onPressed: () => _showMoveDialog(context),
              color: AppColors.getPrimaryText(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
              color: AppColors.getPrimaryText(context),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.getPrimaryBackground(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getSecondaryBackground(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.getTertiaryBackground(context),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField с поддержкой мультистрок

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(
                  color: AppColors.getPrimaryText(context),
                  letterSpacing: -0.2,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.getSecondaryText(context),
                    letterSpacing: -0.2,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => widget.onSendPressed(),
              ),
            ),

            // Нижняя панель с кнопками

            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Кнопка прикрепления

                  _AttachButton(
                    onPressed: widget.onAttachPressed,
                  ),

                  const Spacer(),

                  // Кнопка отправки

                  _SendButton(
                    onPressed: widget.onSendPressed,
                    isEnabled: !isTextEmpty,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDialog(BuildContext context) {
    // ... код диалога перемещения
  }
}

class _AttachButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AttachButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.getTertiaryBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            size: 20,
            color: AppColors.getPrimaryText(context),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;

  final bool isEnabled;

  const _SendButton({
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.getAccentBackground(context)
                : AppColors.getSecondaryText(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.arrow_upward,
            size: 16,
            color: AppColors.getAccentText(context),
          ),
        ),
      ),
    );
  }
}
