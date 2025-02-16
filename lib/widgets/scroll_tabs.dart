import 'package:flutter/material.dart';

class ScrollTabs extends StatefulWidget {
  final List<String> tabs;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });
  }

  @override
  void didUpdateWidget(ScrollTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToSelectedTab();
    }
  }

  void _scrollToSelectedTab() {
    final RenderBox tabBox = _tabKeys[widget.selectedIndex]
        .currentContext
        ?.findRenderObject() as RenderBox;
    final RenderBox listBox = context.findRenderObject() as RenderBox;

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
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  return GestureDetector(
                    onTap: () => widget.onTabSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          Colors.grey[200],
                          Theme.of(context).primaryColor,
                          value,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.tabs[index],
                        style: TextStyle(
                          color: Color.lerp(
                            Colors.black,
                            Colors.white,
                            value,
                          ),
                          fontWeight: FontWeight.lerp(
                            FontWeight.normal,
                            FontWeight.bold,
                            value,
                          ),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  );
                },
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
