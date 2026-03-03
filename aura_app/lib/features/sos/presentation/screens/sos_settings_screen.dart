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
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.backgroundGradient(brightness),
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
                      ? Center(
                          child: Text(
                            'Please log in to access SOS settings',
                            style: TextStyle(
                              color: AppColors.onSurfaceMuted(brightness),
                            ),
                          ),
                        )
                      : _buildContent(responsive, user.uid, brightness),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive responsive) {
    return const AppHeader(title: 'SOS Settings');
  }

  Widget _buildContent(
    Responsive responsive,
    String oderId,
    Brightness brightness,
  ) {
    final settingsAsync = ref.watch(sosSettingsProvider(oderId));
    final contactsAsync = ref.watch(trustedContactsProvider(oderId));

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: responsive.h(2)),
          _buildSectionTitle('Emergency Message', brightness),
          SizedBox(height: responsive.h(1)),
          settingsAsync.when(
            data: (settings) => _buildMessageCard(
              responsive,
              oderId,
              settings.customMessage,
              brightness,
            ),
            loading: () => _buildLoadingCard(responsive, brightness),
            error: (e, _) =>
                _buildErrorCard(responsive, e.toString(), brightness),
          ),
          SizedBox(height: responsive.h(3)),
          _buildSectionHeader(
            'Trusted Contacts',
            _showAddContactSheet,
            brightness,
          ),
          SizedBox(height: responsive.h(1)),
          contactsAsync.when(
            data: (contacts) {
              if (contacts.isEmpty) {
                return _buildEmptyContactsCard(responsive, brightness);
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
            loading: () => _buildLoadingCard(responsive, brightness),
            error: (e, _) =>
                _buildErrorCard(responsive, e.toString(), brightness),
          ),
          SizedBox(height: responsive.h(3)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Brightness brightness) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.onSurface(brightness),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    VoidCallback onAdd,
    Brightness brightness,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.onSurface(brightness),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: AppColors.onSurface(brightness),
          ),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildMessageCard(
    Responsive responsive,
    String oderId,
    String message,
    Brightness brightness,
  ) {
    if (!_isEditingMessage) {
      _messageController.text = message;
    }

    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditingMessage)
            TextField(
              controller: _messageController,
              style: TextStyle(color: AppColors.onSurface(brightness)),
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your emergency message...',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceFaint(brightness),
                ),
              ),
            )
          else
            Text(
              message,
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted(brightness),
                    ),
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
                  child: Text(
                    'Save',
                    style: TextStyle(color: AppColors.onSurface(brightness)),
                  ),
                ),
              ] else
                TextButton.icon(
                  onPressed: () => setState(() => _isEditingMessage = true),
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.onSurfaceMuted(brightness),
                    size: 18,
                  ),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted(brightness),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContactsCard(Responsive responsive, Brightness brightness) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            color: AppColors.onSurfaceFaint(brightness),
            size: 48,
          ),
          SizedBox(height: responsive.h(1)),
          Text(
            'No trusted contacts yet',
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: 16,
            ),
          ),
          SizedBox(height: responsive.h(0.5)),
          Text(
            'Add contacts who will be notified in an emergency',
            style: TextStyle(
              color: AppColors.onSurfaceFaint(brightness),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(Responsive responsive, Brightness brightness) {
    return Container(
      padding: EdgeInsets.all(responsive.w(6)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard(
    Responsive responsive,
    String error,
    Brightness brightness,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        error,
        style: TextStyle(color: AppColors.onSurface(brightness)),
      ),
    );
  }
}
