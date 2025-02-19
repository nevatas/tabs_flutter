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
import 'package:google_fonts/google_fonts.dart';
import '../models/tab_item.dart';
import 'package:flutter/services.dart';

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
  double? _dragStartX;

  @override
  void initState() {
    super.initState();
    _messageManager = MessageManager(StorageService());
    _tabManager = TabManager(
      pageController: CustomPageController(),
    );

    _focusNode.addListener(_onFocusChanged);

    _messageManager.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = _tabManager.scrollControllers[_tabManager.selectedTabIndex];
        if (controller?.hasClients ?? false) {
          final position = controller!.position;
          if (position.pixels > position.maxScrollExtent - 300) {
            controller.animateTo(
              position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final message = Message(
      text: _textController.text,
      isMe: true,
      timestamp: DateTime.now(),
      tabIndex: _tabManager.selectedTabIndex,
    );

    _textController.clear();
    
    // Сначала добавляем сообщение в список
    await _messageManager.sendMessage(message);
    setState(() {});

    // Затем ждем следующего кадра для корректного скролла
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _tabManager.scrollControllers[_tabManager.selectedTabIndex];
      if (controller?.hasClients ?? false) {
        controller!.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageList(int tabIndex) {
    final messages = _messageManager.messagesByTabIndex[tabIndex] ?? [];

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_tabManager.tabs[tabIndex].emoji != null) ...[
              Text(
                _tabManager.tabs[tabIndex].emoji!,
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Column(
              children: [
                Text(
                  _tabManager.tabs[tabIndex].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.getPrimaryText(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Напишите первую заметку',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.getSecondaryText(context),
                    fontSize: 17,
                    letterSpacing: 0.2,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: PageStorageKey(tabIndex),
      controller: _tabManager.scrollControllers[tabIndex],
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16,
      ),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(
          message: messages[index],
          isSelectionMode: _messageManager.isSelectionMode,
          isSelected: _messageManager.selectedMessages.contains(messages[index]),
          onLongPress: () {
            setState(() {
              _messageManager.toggleSelectionMode();
              _messageManager.toggleMessageSelection(messages[index]);
            });
          },
          onSelect: () {
            setState(() {
              _messageManager.toggleMessageSelection(messages[index]);
            });
          },
        );
      },
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
          onTabSelected: (index) {
            setState(() {
              _tabManager.handleTabSelection(index, fromDrawer: true);
            });
          },
          onCreateTab: (title) {
            print('🔵 ChatScreen.onCreateTab:');
            print('  Входящий title: $title');

            setState(() {
              final parts = title.split(' ');
              String? emoji;
              String tabTitle;

              if (parts.isNotEmpty && isEmoji(parts.first)) {
                emoji = parts.first;
                tabTitle = parts.skip(1).join(' ');
              } else {
                emoji = null;
                tabTitle = title;
              }

              print('  Разобранные данные:');
              print('    emoji: $emoji');
              print('    tabTitle: $tabTitle');

              if (tabTitle.isEmpty) {
                print('  ⚠️ Пустое название таба, отмена создания');
                return;
              }

              final newTab = TabItem(
                emoji: emoji,
                title: tabTitle,
              );

              final newTabs = List<TabItem>.from(_tabManager.tabs);
              final newIndex = newTabs.length;
              print('  Текущее количество табов: ${_tabManager.tabs.length}');
              print('  Новый индекс: $newIndex');

              newTabs.add(newTab);
              _tabManager.updateTabs(newTabs);
              
              // Инициализируем пустой список сообщений для нового таба
              _messageManager.messagesByTabIndex[newIndex] ??= [];
              
              _tabManager.handleTabSelection(newIndex, fromDrawer: true);
            });
          },
        ),
        drawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              if (_tabManager.selectedTabIndex == 0) {
                _dragStartX = details.globalPosition.dx;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (_tabManager.selectedTabIndex == 0 &&
                  _dragStartX != null &&
                  details.globalPosition.dx - _dragStartX! > 50) {
                _dragStartX = null;
                Scaffold.of(context).openDrawer();
              }
            },
            onHorizontalDragEnd: (_) {
              _dragStartX = null;
            },
            child: Column(
              children: [
                Builder(
                  builder: (context) => Header(
                    onMenuPressed: () {
                      _focusNode.unfocus();
                      Scaffold.of(context).openDrawer();
                    },
                    isSelectionMode: _messageManager.isSelectionMode,
                    onExitSelectionMode: () {
                      setState(() {
                        _messageManager.toggleSelectionMode();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _tabManager.pageController,
                        itemCount: _tabManager.tabs.length,
                        onPageChanged: (index) {
                          print('🔵 PageView.onPageChanged:');
                          print('  Новый индекс: $index');
                          print('  Текущий индекс TabManager: ${_tabManager.selectedTabIndex}');

                          HapticFeedback.selectionClick();
                          
                          setState(() {
                            _tabManager.selectedTabIndex = index;
                            // Инициализируем пустой список сообщений для таба, если его еще нет
                            _messageManager.messagesByTabIndex[index] ??= [];
                          });
                        },
                        itemBuilder: (context, index) {
                          print('🔵 PageView.itemBuilder:');
                          print('  Строим страницу для индекса: $index');
                          print(
                              '  Количество сообщений: ${_messageManager.messagesByTabIndex[index]?.length ?? 0}');
                          return _buildMessageList(index);
                        },
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: _messageManager.isSelectionMode ? -56 : 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _messageManager.isSelectionMode ? 0 : 1,
                          child: ScrollTabs(
                            tabs: _tabManager.tabs,
                            selectedIndex: _tabManager.selectedTabIndex,
                            onTabSelected: (index) => setState(() {
                              _tabManager.handleTabSelection(index);
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InputBar(
                  controller: _textController,
                  focusNode: _focusNode,
                  onSendPressed: _sendMessage,
                  onAttachPressed: () {},
                  hintText: 'Новая заметка...',
                  isSelectionMode: _messageManager.isSelectionMode,
                  selectedCount: _messageManager.selectedMessages.length,
                  tabManager: _tabManager,
                  onDelete: () async {
                    for (var message in _messageManager.selectedMessages) {
                      await _messageManager.deleteMessage(message);
                    }
                    setState(() {
                      _messageManager.toggleSelectionMode();
                    });
                  },
                  onMove: (index) async {
                    for (var message in _messageManager.selectedMessages) {
                      await _messageManager.moveMessage(message, index);
                    }
                    setState(() {
                      _messageManager.toggleSelectionMode();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    _tabManager.dispose();
    super.dispose();
  }

  bool isEmoji(String text) {
    if (text.isEmpty) return false;

    final runes = text.runes.toList();

    for (final rune in runes) {
      final isInRange =
          (rune >= 0x1F300 && rune <= 0x1F9FF) || // Основные эмодзи
              (rune >= 0x2600 && rune <= 0x26FF) || // Разные символы
              (rune >= 0x2700 && rune <= 0x27BF) || // Dingbats
              (rune >= 0xFE00 && rune <= 0xFE0F); // Вариации

      if (!isInRange) {
        return false;
      }
    }

    return true;
  }
}
