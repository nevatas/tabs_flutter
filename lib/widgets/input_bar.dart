import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../managers/tab_manager.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  final VoidCallback onSendPressed;

  final VoidCallback onAttachPressed;

  final String hintText;

  final bool isSelectionMode;

  final int selectedCount;

  final VoidCallback onDelete;

  final Function(int) onMove;

  final TabManager tabManager;

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
    required this.tabManager,
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
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryBackground(context),
            blurRadius: 16,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: AppColors.getPrimaryBackground(context),
            blurRadius: 16,
            spreadRadius: 8,
          ),
        ],
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: widget.isSelectionMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: Container(
          decoration: BoxDecoration(
            color: AppColors.getSecondaryBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.getTertiaryBackground(context),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '${widget.selectedCount} выбрано',
                  style: TextStyle(
                    color: AppColors.getPrimaryText(context),
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete),
                onPressed: widget.onDelete,
                color: AppColors.getPrimaryText(context),
                iconSize: 24,
              ),
              const SizedBox(width: 8),
              // Padding(
              //   padding: const EdgeInsets.only(right: 16),
              //   child: Row(
              //     children: [
              //       // PopupMenuButton<int>(
              //       //   itemBuilder: (context) => List.generate(
              //       //     widget.tabManager.tabs.length,
              //       //     (index) => PopupMenuItem(
              //       //       value: index,
              //       //       child: Text(widget.tabManager.tabs[index].title),
              //       //     ),
              //       //   ),
              //       //   onSelected: widget.onMove,
              //       // ),

              //     ],
              //   ),
              // ),
            ],
          ),
        ),
        secondChild: Container(
          decoration: BoxDecoration(
            color: AppColors.getSecondaryBackground(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.getTertiaryBackground(context),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Stack(
            children: [
              TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                style: TextStyle(
                  color: AppColors.getPrimaryText(context),
                  fontSize: 17,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.getSecondaryText(context),
                    letterSpacing: 0.2,
                  ),
                  contentPadding: EdgeInsets.only(left: 16, right: 16 + 32),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => widget.onSendPressed(),
              ),
              Positioned(
                right: 16,
                bottom: 6,
                child: _SendButton(
                  onPressed: widget.onSendPressed,
                  isEnabled: !isTextEmpty,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _AttachButton extends StatelessWidget {
//   final VoidCallback onPressed;

//   const _AttachButton({
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: AppColors.getTertiaryBackground(context),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withAlpha(41),
//                 blurRadius: 2,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Icon(
//             Icons.add,
//             size: 20,
//             color: AppColors.getPrimaryText(context),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
            color: isEnabled ? AppColors.getAccentBackground(context) : AppColors.getSecondaryText(context),
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
