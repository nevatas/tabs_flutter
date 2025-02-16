import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/scroll_tabs.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../models/message.dart';
import '../services/storage_service.dart';
import '../managers/message_manager.dart';
import '../managers/tab_manager.dart';
import '../controllers/custom_page_controller.dart';
import '../theme/app_colors.dart';
import 'package:flutter/rendering.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late final MessageManager _messageManager;
  late final TabManager _tabManager;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messageManager = MessageManager(StorageService());
    _tabManager = TabManager(
      pageController: CustomPageController(),
    );

    _messageManager.initialize();
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final message = Message(
      text: _textController.text,
      isMe: true,
      timestamp: DateTime.now(),
      category: _tabManager.currentCategory,
    );

    _textController.clear();
    await _messageManager.sendMessage(message);
    setState(() {});

    final controller =
        _tabManager.scrollControllers[_tabManager.currentCategory];
    if (controller?.hasClients ?? false) {
      await controller!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageList(MessageCategory category) {
    final messages = _messageManager.messagesByCategory[category]!;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent * 0.8) {
            _messageManager.loadMoreMessages(category);
          }
        }
        return false;
      },
      child: ListView.builder(
        key: PageStorageKey(category),
        controller: _tabManager.scrollControllers[category],
        reverse: true,
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        clipBehavior: Clip.none,
        itemCount:
            messages.length + (_messageManager.isLoading[category]! ? 1 : 0),
        itemBuilder: (context, index) {
          final messageIndex = messages.length - 1 - index;

          if (messageIndex < 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return MessageBubble(
            message: messages[messageIndex],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.getPrimaryBackground(context),
        drawer: SideMenu(
          tabs: _tabManager.tabs,
          selectedIndex: _tabManager.selectedTabIndex,
          onTabSelected: (index) => setState(() {
            _tabManager.handleTabSelection(index, fromDrawer: true);
          }),
        ),
        drawerEdgeDragWidth: _tabManager.selectedTabIndex == 0
            ? MediaQuery.of(context).size.width
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Builder(
                builder: (context) => Header(
                  onMenuPressed: () {
                    _focusNode.unfocus();
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              ScrollTabs(
                tabs: _tabManager.tabs,
                selectedIndex: _tabManager.selectedTabIndex,
                onTabSelected: (index) => setState(() {
                  _tabManager.handleTabSelection(index);
                }),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _tabManager.pageController,
                  itemCount: MessageCategory.values.length,
                  onPageChanged: (index) {
                    setState(() {
                      _tabManager.selectedTabIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final category = MessageCategory.values[index];
                    return _buildMessageList(category);
                  },
                ),
              ),
              InputBar(
                controller: _textController,
                focusNode: _focusNode,
                onSendPressed: _sendMessage,
                onAttachPressed: () {},
                hintText: 'Новая заметка...',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _tabManager.dispose();
    super.dispose();
  }
}
