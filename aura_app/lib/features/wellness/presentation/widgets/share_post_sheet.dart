import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../messaging/presentation/providers/messaging_provider.dart';
import '../../data/models/wellness_update.dart';

class SharePostSheet extends ConsumerStatefulWidget {
  final WellnessUpdate post;

  const SharePostSheet({super.key, required this.post});

  @override
  ConsumerState<SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends ConsumerState<SharePostSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _shareToConversation(String conversationId, String otherUserName) async {
    final notifier = ref.read(messagingProvider.notifier);

    final content = 'shared_post:${widget.post.id}';

    await notifier.sendMessage(conversationId, content);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shared to $otherUserName'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagingState = ref.watch(messagingProvider);

    final filteredConversations = messagingState.conversations.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.otherUserName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Send to',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search friends...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Icon(Icons.search, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: filteredConversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No recent chats'
                              : 'No friends found',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conv = filteredConversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accent.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            conv.otherUserName.isNotEmpty
                                ? conv.otherUserName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          conv.otherUserName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () =>
                              _shareToConversation(conv.id, conv.otherUserName),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Send'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
