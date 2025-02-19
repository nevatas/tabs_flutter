import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/tab_item.dart';

class ScrollTabs extends StatefulWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const ScrollTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<ScrollTabs> createState() => _ScrollTabsState();
}

class _ScrollTabsState extends State<ScrollTabs> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _tabKeys.addAll(List.generate(
      widget.tabs.length,
      (index) => GlobalKey(),
    ));
  }

  @override
  void didUpdateWidget(ScrollTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем _tabKeys, если изменилось количество табов
    if (widget.tabs.length != oldWidget.tabs.length) {
      _tabKeys.clear();
      _tabKeys.addAll(List.generate(
        widget.tabs.length,
        (index) => GlobalKey(),
      ));
    }

    // Прокручиваем к выбранному табу
    if (widget.selectedIndex != oldWidget.selectedIndex &&
        widget.selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }
  }

  void _scrollToSelectedTab() {
    if (!mounted) return;

    // Проверяем валидность индекса
    if (widget.selectedIndex >= _tabKeys.length) return;

    final context = _tabKeys[widget.selectedIndex].currentContext;
    if (context == null) return;

    final RenderBox tabBox = context.findRenderObject() as RenderBox;
    final RenderBox listBox = this.context.findRenderObject() as RenderBox;

    final double tabCenter =
        tabBox.localToGlobal(Offset.zero).dx + tabBox.size.width / 2;
    final double listCenter =
        listBox.localToGlobal(Offset.zero).dx + listBox.size.width / 2;

    final double scrollOffset =
        _scrollController.offset + (tabCenter - listCenter);

    _scrollController.animateTo(
      scrollOffset.clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 ScrollTabs.build:');
    print('  Количество табов: ${widget.tabs.length}');
    print('  Выбранный индекс: ${widget.selectedIndex}');
    print(
        '  Табы: ${widget.tabs.map((t) => "${t.emoji ?? ''} ${t.title}").toList()}');

    return Container(
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
      child: Container(
        color: AppColors.getPrimaryBackground(context),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
              widget.tabs.length,
              (index) => Padding(
                key: _tabKeys[index],
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 4.0,
                  right: index == widget.tabs.length - 1 ? 16.0 : 4.0,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0.0,
                    end: widget.selectedIndex == index ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    final isSelected = widget.selectedIndex == index;
                    return GestureDetector(
                      onTap: () => widget.onTabSelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                                AppColors.getPrimaryBackground(context),
                                AppColors.getSecondaryBackground(context),
                                value,
                              ) ??
                              AppColors.getPrimaryBackground(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color.lerp(
                                  AppColors.getDividedColor(context),
                                  AppColors.getTertiaryBackground(context),
                                  value,
                                ) ??
                                AppColors.getDividedColor(context),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.tabs[index].emoji != null) ...[
                              Text(
                                widget.tabs[index].emoji!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.tabs[index].title,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.getPrimaryText(context)
                                    : AppColors.getSecondaryText(context),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    _scrollController.dispose();
    super.dispose();
  }
}
