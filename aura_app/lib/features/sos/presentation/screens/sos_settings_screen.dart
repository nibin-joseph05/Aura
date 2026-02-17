import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/sos_provider.dart';
import '../widgets/add_contact_bottom_sheet.dart';
import '../widgets/trusted_contact_card.dart';

class SOSSettingsScreen extends ConsumerStatefulWidget {
  const SOSSettingsScreen({super.key});

  @override
  ConsumerState<SOSSettingsScreen> createState() => _SOSSettingsScreenState();
}

class _SOSSettingsScreenState extends ConsumerState<SOSSettingsScreen> {
  final _messageController = TextEditingController();
  bool _isEditingMessage = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showAddContactSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddContactBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final user = ref.watch(currentUserProvider);

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
              _buildHeader(context, responsive),
              Expanded(
                child: user == null
                    ? const Center(
                        child: Text(
                          'Please log in to access SOS settings',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : _buildContent(responsive, user.uid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive responsive) {
    return const AppHeader(title: 'SOS Settings');
  }

  Widget _buildContent(Responsive responsive, String oderId) {
    final settingsAsync = ref.watch(sosSettingsProvider(oderId));
    final contactsAsync = ref.watch(trustedContactsProvider(oderId));

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: responsive.h(2)),
          _buildSectionTitle('Emergency Message'),
          SizedBox(height: responsive.h(1)),
          settingsAsync.when(
            data: (settings) =>
                _buildMessageCard(responsive, oderId, settings.customMessage),
            loading: () => _buildLoadingCard(responsive),
            error: (e, _) => _buildErrorCard(responsive, e.toString()),
          ),
          SizedBox(height: responsive.h(3)),
          _buildSectionHeader('Trusted Contacts', _showAddContactSheet),
          SizedBox(height: responsive.h(1)),
          contactsAsync.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return _buildEmptyContactsCard(responsive);
              }
              return Column(
                children: contacts
                    .map(
                      (contact) =>
                          TrustedContactCard(contact: contact, oderId: oderId),
                    )
                    .toList(),
              );
            },
            loading: () => _buildLoadingCard(responsive),
            error: (e, _) => _buildErrorCard(responsive, e.toString()),
          ),
          SizedBox(height: responsive.h(3)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildMessageCard(
    Responsive responsive,
    String oderId,
    String message,
  ) {
    if (!_isEditingMessage) {
      _messageController.text = message;
    }

    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditingMessage)
            TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your emergency message...',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            )
          else
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
              ),
            ),
          SizedBox(height: responsive.h(1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isEditingMessage) ...[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditingMessage = false;
                      _messageController.text = message;
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final notifier = ref.read(sosNotifierProvider.notifier);
                    await notifier.updateMessage(
                      oderId,
                      _messageController.text,
                    );
                    if (mounted) {
                      setState(() => _isEditingMessage = false);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else
                TextButton.icon(
                  onPressed: () => setState(() => _isEditingMessage = true),
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContactsCard(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            color: Colors.white.withValues(alpha: 0.5),
            size: 48,
          ),
          SizedBox(height: responsive.h(1)),
          Text(
            'No trusted contacts yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: responsive.h(0.5)),
          Text(
            'Add contacts who will be notified in an emergency',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard(Responsive responsive, String error) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(error, style: const TextStyle(color: Colors.white)),
    );
  }
}
