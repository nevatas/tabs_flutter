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

    setState(() {
      _messageManager.sendMessage(message);
    });

    _textController.clear();

    final controller =
        _tabManager.scrollControllers[_tabManager.currentCategory];
    if (controller?.hasClients ?? false) {
      controller!.animateTo(
        controller.position.maxScrollExtent + 100,
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
        padding: const EdgeInsets.all(16),
        itemCount:
            messages.length + (_messageManager.isLoading[category]! ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return MessageBubble(
            message: messages[index],
            onMove: (newCategory) async {
              try {
                await _messageManager.moveMessage(messages[index], newCategory);
                setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Не удалось переместить сообщение')),
                  );
                }
              }
            },
            onDelete: () async {
              try {
                await _messageManager.deleteMessage(messages[index]);
                setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Не удалось удалить сообщение')),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        tabs: _tabManager.tabs,
        selectedIndex: _tabManager.selectedTabIndex,
        onTabSelected: (index) => setState(() {
          _tabManager.handleTabSelection(index, fromDrawer: true);
        }),
      ),
      onDrawerChanged: (isOpened) {
        if (!isOpened && _tabManager.pendingTabIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _tabManager.handleTabSelection(_tabManager.pendingTabIndex!);
              _tabManager.pendingTabIndex = null;
            });
          });
        }
      },
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (context) => Header(
                onMenuPressed: () => Scaffold.of(context).openDrawer(),
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
                pageSnapping: false,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final category = MessageCategory.values[index];
                  return _buildMessageList(category);
                },
              ),
            ),
            InputBar(
              controller: _textController,
              onSendPressed: _sendMessage,
              onAttachPressed: () {},
              hintText: _tabManager
                  .getHintTextForCategory(_tabManager.currentCategory),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabManager.dispose();
    super.dispose();
  }
}
