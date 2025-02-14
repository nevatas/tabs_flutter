import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/scroll_tabs.dart';
import '../models/message.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final StorageService _storage = StorageService();

  // Сообщения по категориям
  final Map<MessageCategory, List<Message>> _messagesByCategory = {
    MessageCategory.inbox: [],
    MessageCategory.books: [],
    MessageCategory.ideas: [],
    MessageCategory.words: [],
    MessageCategory.quotes: [],
  };

  // Флаги для пагинации
  final Map<MessageCategory, bool> _hasMoreMessages = {
    for (var category in MessageCategory.values) category: true
  };

  final Map<MessageCategory, bool> _isLoading = {
    for (var category in MessageCategory.values) category: false
  };

  // Контроллеры
  late final PageController _pageController;
  final Map<MessageCategory, ScrollController> _scrollControllers = {};
  final _textController = TextEditingController();
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Inbox',
    'Books',
    'Ideas',
    'Words',
    'Quotes',
  ];

  MessageCategory get _currentCategory =>
      MessageCategory.values[_selectedTabIndex];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);

    // Инициализируем скролл контроллеры
    for (var category in MessageCategory.values) {
      _scrollControllers[category] = ScrollController();
    }

    // Инициализируем хранилище
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    await _storage.init();
    // Загружаем начальные данные для всех категорий
    for (var category in MessageCategory.values) {
      await _loadMoreMessages(category);
    }
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final message = Message(
      text: _textController.text,
      isMe: true,
      timestamp: DateTime.now(),
      category: _currentCategory,
    );

    // Сохраняем сообщение в файл
    await _storage.saveMessage(message);

    setState(() {
      _messagesByCategory[_currentCategory]!.insert(0, message);
    });

    _textController.clear();

    // Прокрутка к началу списка (так как новые сообщения добавляются сверху)
    final controller = _scrollControllers[_currentCategory];
    if (controller?.hasClients ?? false) {
      controller!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMoreMessages(MessageCategory category) async {
    // Проверяем можно ли загружать еще
    if (_isLoading[category]! || !_hasMoreMessages[category]!) return;

    setState(() {
      _isLoading[category] = true;
    });

    try {
      final messages = await _storage.loadMessages(
        category,
        limit: 20,
        before: _messagesByCategory[category]!.isEmpty
            ? null
            : _messagesByCategory[category]!.last.timestamp,
      );

      if (mounted) {
        setState(() {
          _messagesByCategory[category]!.addAll(messages);
          // Если получили меньше 20 сообщений, значит это последняя порция
          _hasMoreMessages[category] = messages.length == 20;
        });
      }
    } catch (e) {
      // Здесь можно добавить обработку ошибок
      print('Error loading messages: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading[category] = false;
        });
      }
    }
  }

  void _handleTabSelection(int index) {
    final int currentIndex = _selectedTabIndex;
    setState(() {
      _selectedTabIndex = index;
    });

    // Анимируем только если разница в один таб
    if ((index - currentIndex).abs() == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  Widget _buildMessageList(MessageCategory category) {
    final messages = _messagesByCategory[category]!;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // Начинаем подгрузку когда доскроллили до 80% списка
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent * 0.8) {
            _loadMoreMessages(category);
          }
        }
        return false;
      },
      child: ListView.builder(
        key: PageStorageKey(category),
        controller: _scrollControllers[category],
        padding: const EdgeInsets.all(16),
        // Добавляем +1 к количеству элементов если идет загрузка
        itemCount: messages.length + (_isLoading[category]! ? 1 : 0),
        itemBuilder: (context, index) {
          // Показываем индикатор загрузки последним элементом
          if (index == messages.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return MessageBubble(message: messages[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScrollTabs(
          tabs: _tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: _handleTabSelection,
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: MessageCategory.values.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
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
              onSendPressed: _sendMessage,
              onAttachPressed: () {
                // TODO: Логика для прикрепления файлов
              },
              hintText: _getHintTextForCategory(_currentCategory),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintTextForCategory(MessageCategory category) {
    switch (category) {
      case MessageCategory.inbox:
        return 'Введите сообщение...';
      case MessageCategory.books:
        return 'Добавьте заметку о книге...';
      case MessageCategory.ideas:
        return 'Запишите свою идею...';
      case MessageCategory.words:
        return 'Добавьте новое слово...';
      case MessageCategory.quotes:
        return 'Введите цитату...';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
