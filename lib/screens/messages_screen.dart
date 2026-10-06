import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_colors.dart';
import '../widgets/app_brand_logo.dart';
import 'location_service.dart';
import 'native_dialer.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  static const _chatHistoryKey = 'chat_messages_v1';
  static const _deletedChatsKey = 'chat_deleted_v1';
  static const _blockedChatsKey = 'chat_blocked_v1';
  bool _isInChat = false;
  String _currentChatWith = "";
  String _currentChatImage = "";
  String? _currentChatPhone;
  bool _chatNotificationsEnabled = true;
  final Set<String> _deletedChats = {};
  final Set<String> _blockedChats = {};
  final ImagePicker _imagePicker = ImagePicker();
  final Map<String, List<_ChatMessage>> _chatMessages = {
    'Marcus Thorne': [
      _ChatMessage(
        isMe: false,
        text: "Good morning! I'm your assigned technician for today's desludging.",
        time: '09:15 AM',
      ),
      _ChatMessage(
        isMe: true,
        text: 'Hi Marcus, thank you. Will you need access to the back alley?',
        time: '09:17 AM',
      ),
      _ChatMessage(
        isMe: false,
        text: "Yes, that would be helpful. I'm 5 minutes away.",
        time: '09:22 AM',
      ),
    ],
  };

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _deletedChats.addAll(preferences.getStringList(_deletedChatsKey) ?? []);
        _blockedChats.addAll(preferences.getStringList(_blockedChatsKey) ?? []);
      });
    }
    final stored = preferences.getString(_chatHistoryKey);
    if (stored == null) return;
    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final messages = <String, List<_ChatMessage>>{};
      for (final entry in decoded.entries) {
        messages[entry.key] = (entry.value as List<dynamic>)
            .map(
              (item) => _ChatMessage.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _chatMessages
          ..clear()
          ..addAll(messages);
      });
    } catch (_) {
      // Ignore malformed local chat history and keep the built-in demo thread.
    }
  }

  Future<void> _persistChatHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_deletedChatsKey, _deletedChats.toList());
    await preferences.setStringList(_blockedChatsKey, _blockedChats.toList());
    await preferences.setString(
      _chatHistoryKey,
      jsonEncode(
        _chatMessages.map(
          (name, messages) => MapEntry(
            name,
            messages.map((message) => message.toJson()).toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _openChat(String name, String imageUrl) {
    if (_blockedChats.contains(name)) return;
    setState(() {
      _isInChat = true;
      _currentChatWith = name;
      _currentChatImage = imageUrl;
      _currentChatPhone = null;
      _chatMessages.putIfAbsent(name, () => []);
    });
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.putIfAbsent(_currentChatWith, () => []).add(
        _ChatMessage(
          isMe: true,
          text: text,
          time: TimeOfDay.now().format(context),
        ),
      );
    });
    _persistChatHistory();
    _messageController.clear();
  }

  Future<void> _showAttachmentOptions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(sheetContext, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload Images'),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Share Location'),
              onTap: () => Navigator.pop(sheetContext, 'location'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'location') {
      await _shareCurrentLocation();
      return;
    }
    try {
      final image = await _imagePicker.pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final extension = image.path.contains('.')
          ? image.path.substring(image.path.lastIndexOf('.'))
          : '.jpg';
      final savedImage = await File(image.path).copy(
        '${directory.path}/chat_${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      setState(() {
        _chatMessages.putIfAbsent(_currentChatWith, () => []).add(
          _ChatMessage(
            isMe: true,
            text: 'Image',
            time: TimeOfDay.now().format(context),
            imagePath: savedImage.path,
          ),
        );
      });
      await _persistChatHistory();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the image picker.')),
      );
    }
  }

  Future<void> _shareCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required.')),
        );
        return;
      }
      final link =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      setState(() {
        _chatMessages.putIfAbsent(_currentChatWith, () => []).add(
          _ChatMessage(
            isMe: true,
            text: 'My location: $link',
            time: TimeOfDay.now().format(context),
          ),
        );
      });
      await _persistChatHistory();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your current location.')),
      );
    }
  }

  Future<void> _handleChatMenuAction(String action) async {
    if (action == 'report') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted for $_currentChatWith.')),
      );
      return;
    }
    if (action == 'settings') {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Chat settings'),
            content: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notifications'),
              value: _chatNotificationsEnabled,
              onChanged: (value) {
                setState(() => _chatNotificationsEnabled = value);
                setDialogState(() {});
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final contact = _currentChatWith;
    final isDelete = action == 'delete';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isDelete ? 'Delete chat?' : 'Block contact?'),
        content: Text(
          isDelete
              ? 'Remove the conversation with $contact from your chat list?'
              : 'Block $contact from contacting you?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isDelete ? 'Delete' : 'Block'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        if (isDelete) {
          _deletedChats.add(contact);
          _chatMessages.remove(contact);
        } else {
          _blockedChats.add(contact);
        }
        _isInChat = false;
      });
      await _persistChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: _isInChat ? _buildChatScreen() : _buildMessagesList(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (_isInChat) {
      return AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => setState(() => _isInChat = false),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(_currentChatImage),
              onBackgroundImageError: (_, _) {},
              child: _currentChatImage.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentChatWith,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: context.appText,
                  ),
                ),
                Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: context.appAccent),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Call operator',
            onPressed: () => openNativeDialer(
              context,
              phoneNumber: _currentChatPhone,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: _handleChatMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Chat settings')),
              PopupMenuItem(value: 'delete', child: Text('Delete chat')),
              PopupMenuItem(value: 'block', child: Text('Block contact')),
              PopupMenuItem(value: 'report', child: Text('Report contact')),
            ],
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const AppBrandLogo(size: 28),
          Text(
            "Messages",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appBorder),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: TextStyle(color: context.appMutedText),
                prefixIcon: Icon(Icons.search, color: context.appMutedText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Chat List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              if (!_deletedChats.contains('Marcus Thorne') &&
                  !_blockedChats.contains('Marcus Thorne'))
                _buildChatListItem(
                name: "Marcus Thorne",
                role: "Lead Technician",
                message: "I am 5 minutes away from your location.",
                time: "2m ago",
                unread: 1,
                imageUrl:
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuDnhjs4eedidLmamRpW_I6QnhAiZ298TE3VAPUCGsG2EBKvx9HDIuAtj4iN-86laykTvKvkCGQ3RiSDB72iOkVc4cNIwr28_6zjqzlFDBwPaqskueImQPChosZt3qC_RFS-6H0crkTfU81I2utb_3ydMaSFInBiYDutzqzJDgs6wf1407sFXRZuEdlt-5pC3Y8_-eYXSTw78MlKmSx-iaLvocKb9mrQMb8x9ZeOWJF9bJKVv43yHr0DJMUG3-dnChOZPf3i1icox_i3",
                onTap: () => _openChat(
                  'Marcus Thorne',
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDnhjs4eedidLmamRpW_I6QnhAiZ298TE3VAPUCGsG2EBKvx9HDIuAtj4iN-86laykTvKvkCGQ3RiSDB72iOkVc4cNIwr28_6zjqzlFDBwPaqskueImQPChosZt3qC_RFS-6H0crkTfU81I2utb_3ydMaSFInBiYDutzqzJDgs6wf1407sFXRZuEdlt-5pC3Y8_-eYXSTw78MlKmSx-iaLvocKb9mrQMb8x9ZeOWJF9bJKVv43yHr0DJMUG3-dnChOZPf3i1icox_i3",
                ),
              ),
              if (!_deletedChats.contains('Sarah Jenkins') &&
                  !_blockedChats.contains('Sarah Jenkins'))
                _buildChatListItem(
                name: "Sarah Jenkins",
                role: "Field Expert",
                message: "The soil analysis report is ready for review.",
                time: "1h ago",
                unread: 0,
                imageUrl: "https://picsum.photos/id/64/200/200",
                onTap: () =>
                    _openChat('Sarah Jenkins', 'https://picsum.photos/id/64/200/200'),
              ),
              if (!_deletedChats.contains('Eco-Dispatch System') &&
                  !_blockedChats.contains('Eco-Dispatch System'))
                _buildChatListItem(
                name: "Eco-Dispatch System",
                role: "Automated Assistant",
                message: "Your service SR-2026-001 has been scheduled.",
                time: "Yesterday",
                unread: 0,
                imageUrl: "https://picsum.photos/id/1015/200/200",
                onTap: () => _openChat(
                  'Eco-Dispatch System',
                  'https://picsum.photos/id/1015/200/200',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatListItem({
    required String name,
    required String role,
    required String message,
    required String time,
    required int unread,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    final chatMessages = _chatMessages[name];
    final lastMessage =
        chatMessages == null || chatMessages.isEmpty ? null : chatMessages.last;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.appBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, _) {},
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: context.appText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessage?.time ?? time,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appMutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(fontSize: 12, color: context.appMutedText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage?.text == 'Image'
                        ? 'Photo'
                        : lastMessage?.text ?? message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0
                          ? context.appText
                          : context.appMutedText,
                      fontWeight: unread > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.appAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: TextStyle(
                    color: context.appOnAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatScreen() {
    return Column(
      children: [
        // Messages
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Service request accepted • Oct 24, 2023",
                    style: TextStyle(fontSize: 12, color: context.appMutedText),
                  ),
                ),
              ),
              for (final message
                  in _chatMessages[_currentChatWith] ?? const <_ChatMessage>[])
                _buildMessageBubble(
                  isMe: message.isMe,
                  message: message.text,
                  time: message.time,
                  imagePath: message.imagePath,
                ),
            ],
          ),
        ),

        // Input Bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: context.appSurface,
            border: Border(top: BorderSide(color: context.appBorder)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: context.appAccent,
                  ),
                  tooltip: 'Attach',
                  onPressed: _showAttachmentOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendTextMessage(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: context.appMutedText),
                      filled: true,
                      fillColor: context.appSurfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: context.appAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: context.appOnAccent,
                      size: 20,
                    ),
                    onPressed: _sendTextMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String message,
    required String time,
    String? imagePath,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? context.appAccent : context.appSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  width: 220,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 220,
                    height: 80,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message == 'Image' && imagePath != null ? 'Photo' : message,
              style: TextStyle(
                color: isMe ? context.appOnAccent : context.appText,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMe
                    ? context.appOnAccent.withValues(alpha: 0.72)
                    : context.appMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.isMe,
    required this.text,
    required this.time,
    this.imagePath,
  });

  final bool isMe;
  final String text;
  final String time;
  final String? imagePath;

  Map<String, Object?> toJson() => {
    'isMe': isMe,
    'text': text,
    'time': time,
    'imagePath': imagePath,
  };

  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _ChatMessage(
    isMe: json['isMe'] as bool? ?? false,
    text: json['text'] as String? ?? '',
    time: json['time'] as String? ?? '',
    imagePath: json['imagePath'] as String?,
  );
}
