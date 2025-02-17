// widgets/side_menu.dart
import 'package:flutter/material.dart';
import '../models/tab_item.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:smooth_corner/smooth_corner.dart';

class SideMenu extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const SideMenu({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Размытие с фоном E2E2E2
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: const Color(0xFFE2E2E2), // Просто E2E2E2 без прозрачности
            ),
          ),
        ),
        // Само меню
        Drawer(
          width: MediaQuery.of(context).size.width,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: tabs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == tabs.length) {
                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: CreateTabButton(
                              onCreateTab: (String title) {
                                Navigator.pop(context);
                              },
                              index: index,
                              tabsCount: tabs.length + 1,
                            ),
                          ),
                        );
                      }
                      final reversedIndex = tabs.length - index - 1;
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: SideMenuTab(
                            emoji: tabs[reversedIndex].emoji,
                            title: tabs[reversedIndex].title,
                            isSelected: selectedIndex == reversedIndex,
                            onTap: () {
                              onTabSelected(reversedIndex);
                              Navigator.pop(context);
                            },
                            index: index,
                            tabsCount: tabs.length + 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SideMenuTab extends StatefulWidget {
  final String emoji;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;
  final int tabsCount;

  const SideMenuTab({
    super.key,
    required this.emoji,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.tabsCount,
  });

  @override
  State<SideMenuTab> createState() => _SideMenuTabState();
}

class _SideMenuTabState extends State<SideMenuTab> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 * (widget.tabsCount - widget.index - 1)), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: _visible ? 0.0 : -1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 100, 0),
          child: Opacity(
            opacity: value == -1 ? 0 : 1,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SmoothContainer(
          smoothness: 0.6,
          borderRadius: BorderRadius.circular(12),
          color: widget.isSelected
              ? AppColors.getSecondaryBackground(context)
              : AppColors.getPrimaryBackground(context),
          side: widget.isSelected 
              ? BorderSide(
                  color: AppColors.getTertiaryBackground(context),
                  width: 1,
                )
              : BorderSide.none,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.emoji,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: AppColors.getPrimaryText(context),
                        fontSize: 17,
                        letterSpacing: 0.2,
                        fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.normal,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                      child: Text(widget.title),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateTabButton extends StatefulWidget {
  final Function(String) onCreateTab;
  final int index;
  final int tabsCount;

  const CreateTabButton({
    super.key,
    required this.onCreateTab,
    required this.index,
    required this.tabsCount,
  });

  @override
  State<CreateTabButton> createState() => _CreateTabButtonState();
}

class _CreateTabButtonState extends State<CreateTabButton> {
  bool _isEditing = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 * (widget.tabsCount - widget.index - 1)), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: _visible ? 0.0 : -1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 100, 0),
          child: Opacity(
            opacity: value == -1 ? 0 : 1,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SmoothContainer(
          smoothness: 0.6,
          borderRadius: BorderRadius.circular(12),
          color: AppColors.getPrimaryBackground(context),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!_isEditing) {
                  setState(() => _isEditing = true);
                  _focusNode.requestFocus();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_isEditing)
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: AppColors.getPrimaryText(context),
                            fontSize: 17,
                            letterSpacing: 0.2,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              widget.onCreateTab(value);
                            }
                            setState(() => _isEditing = false);
                            _controller.clear();
                          },
                        ),
                      )
                    else
                      Text(
                        'Make a Tab',
                        style: TextStyle(
                          color: AppColors.getSecondaryText(context),
                          fontSize: 17,
                          letterSpacing: 0.2,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
