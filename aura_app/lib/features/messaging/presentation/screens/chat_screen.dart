import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../../core/widgets/loading/ghost_running.dart';
import '../providers/messaging_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagingProvider.notifier).loadMessages(widget.conversationId);
      ref.read(messagingProvider.notifier).markAsRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    ref
        .read(messagingProvider.notifier)
        .sendMessage(widget.conversationId, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(messagingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: widget.otherUserId.length > 12
                    ? '${widget.otherUserId.substring(0, 12)}...'
                    : widget.otherUserId,
              ),
              Expanded(
                child: state.isLoading && state.messages.isEmpty
                    ? const GhostRunning(
                        primaryMessage: 'Loading messages...',
                        secondaryMessage: 'Just a moment',
                      )
                    : state.messages.isEmpty
                    ? _buildEmptyChat(isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(
                            state.messages[index],
                            isDark,
                          );
                        },
                      ),
              ),
              _buildInputBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat(bool isDark) {
    return Center(
      child: Text(
        'Send a message to start the conversation',
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isDark) {
    // TODO: Replace with actual user ID from auth
    final isMine = message.senderId != widget.otherUserId;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary
              : isDark
              ? AppColors.surfaceDark
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isMine
                    ? Colors.white
                    : isDark
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.sentAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
