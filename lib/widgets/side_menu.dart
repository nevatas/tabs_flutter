// widgets/side_menu.dart
import 'package:flutter/material.dart';
import '../models/tab_item.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:smooth_corner/smooth_corner.dart';

class DragToOpenWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onOpenMenu;
  final double dragWidth;

  const DragToOpenWrapper({
    super.key,
    required this.child,
    required this.onOpenMenu,
    this.dragWidth = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: dragWidth,
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              if (details.localPosition.dx <= dragWidth) {
                onOpenMenu();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: Container(),
          ),
        ),
      ],
    );
  }
}

class SideMenu extends StatefulWidget {
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
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isCreateTabFocused = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Просто фон без размытия
        Container(
          color: const Color(0xFFE2E2E2),
        ),
        // Само меню
        Drawer(
          width: MediaQuery.of(context).size.width,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 24,
                      ),
                      itemCount: widget.tabs.length + 1,
                      itemBuilder: (context, index) {
                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: index == 0
                                ? SideMenuTab(
                                    isCreateTab: true,
                                    isSelected: _isCreateTabFocused,
                                    onCreateTab: (String title) {
                                      Navigator.pop(context);
                                    },
                                    onFocusChange: (focused) {
                                      setState(() {
                                        _isCreateTabFocused = focused;
                                      });
                                    },
                                    index: index,
                                    tabsCount: widget.tabs.length + 1,
                                  )
                                : SideMenuTab(
                                    emoji: widget.tabs[index - 1].emoji,
                                    title: widget.tabs[index - 1].title,
                                    isSelected: !_isCreateTabFocused &&
                                        widget.selectedIndex == index - 1,
                                    onTap: () {
                                      print(
                                          '🔵 SideMenu: onTap for index ${index - 1}');
                                      widget.onTabSelected(index - 1);
                                      Future.delayed(Duration.zero, () {
                                        print(
                                            '🔵 SideMenu: calling Navigator.pop');
                                        Navigator.pop(context);
                                      });
                                    },
                                    index: index,
                                    tabsCount: widget.tabs.length + 1,
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SideMenuTab extends StatefulWidget {
  final String? emoji; // Может быть null для состояния создания
  final String? title; // Может быть null для состояния создания
  final bool isSelected;
  final VoidCallback? onTap; // Для обычного таба
  final Function(String)? onCreateTab; // Для таба создания
  final Function(bool)? onFocusChange; // Для таба создания
  final bool isCreateTab; // Флаг, указывающий, что это таб создания
  final int index;
  final int tabsCount;

  const SideMenuTab({
    super.key,
    this.emoji,
    this.title,
    required this.isSelected,
    this.onTap,
    this.onCreateTab,
    this.onFocusChange,
    this.isCreateTab = false,
    required this.index,
    required this.tabsCount,
  });

  @override
  State<SideMenuTab> createState() => _SideMenuTabState();
}

class _SideMenuTabState extends State<SideMenuTab> {
  bool _visible = false;
  bool _isEditing = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });

    if (widget.isCreateTab) {
      _focusNode.addListener(() {
        widget.onFocusChange?.call(_focusNode.hasFocus);
        setState(() {});
      });
    }
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
          color:
              (widget.isCreateTab && _focusNode.hasFocus) || widget.isSelected
                  ? AppColors.getSecondaryBackground(context)
                  : AppColors.getPrimaryBackground(context),
          side: (widget.isCreateTab && _focusNode.hasFocus) || widget.isSelected
              ? BorderSide(
                  color: AppColors.getTertiaryBackground(context),
                  width: 1,
                )
              : BorderSide.none,
          child: Material(
            color: Colors.transparent,
            child: widget.isCreateTab
                ? _buildCreateTab(context)
                : _buildNormalTab(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTab(BuildContext context) {
    return _isEditing
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
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
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      color: AppColors.getPrimaryText(context),
                      fontSize: 17,
                      letterSpacing: 0.2,
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Make a Tab',
                      hintStyle: TextStyle(
                        color: AppColors.getSecondaryText(context),
                        fontSize: 17,
                        letterSpacing: 0.2,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        widget.onCreateTab?.call(value);
                      }
                      setState(() {
                        _isEditing = false;
                        _controller.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              setState(() => _isEditing = true);
              Future.delayed(const Duration(milliseconds: 50), () {
                _focusNode.requestFocus();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
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
          );
  }

  Widget _buildNormalTab(BuildContext context) {
    return InkWell(
      onTap: () {
        print('🔵 SideMenuTab: onTap called');
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.emoji ?? '',
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
                fontWeight:
                    widget.isSelected ? FontWeight.w500 : FontWeight.normal,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
              child: Text(widget.title ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class CreateTabButton extends StatefulWidget {
  final Function(String) onCreateTab;
  final Function(bool) onFocusChange;
  final int index;
  final int tabsCount;

  const CreateTabButton({
    super.key,
    required this.onCreateTab,
    required this.onFocusChange,
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
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });

    _focusNode.addListener(() {
      widget.onFocusChange(_focusNode.hasFocus);
      setState(() {});
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
          color: _focusNode.hasFocus
              ? AppColors.getSecondaryBackground(context)
              : AppColors.getPrimaryBackground(context),
          side: _focusNode.hasFocus
              ? BorderSide(
                  color: AppColors.getTertiaryBackground(context),
                  width: 1,
                )
              : BorderSide.none,
          child: Material(
            color: Colors.transparent,
            child: _isEditing
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                              color: AppColors.getPrimaryText(context),
                              fontSize: 17,
                              letterSpacing: 0.2,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: 'Make a Tab',
                              hintStyle: TextStyle(
                                color: AppColors.getSecondaryText(context),
                                fontSize: 17,
                                letterSpacing: 0.2,
                                fontFamily: GoogleFonts.inter().fontFamily,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                widget.onCreateTab(value);
                              }
                              setState(() {
                                _isEditing = false;
                                _controller.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      setState(() => _isEditing = true);
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _focusNode.requestFocus();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
