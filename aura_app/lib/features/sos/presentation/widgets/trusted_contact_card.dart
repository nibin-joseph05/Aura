import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../data/models/trusted_contact.dart';
import '../providers/sos_provider.dart';

class TrustedContactCard extends ConsumerWidget {
  final TrustedContact contact;
  final String oderId;

  const TrustedContactCard({
    super.key,
    required this.contact,
    required this.oderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(1.5)),
      padding: EdgeInsets.all(responsive.w(4)),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerBorder(brightness)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.onSurface(brightness),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: TextStyle(
                    color: AppColors.onSurface(brightness),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.h(0.3)),
                Text(
                  contact.phone,
                  style: TextStyle(
                    color: AppColors.onSurfaceMuted(brightness),
                    fontSize: 14,
                  ),
                ),
                if (contact.relationship != null &&
                    contact.relationship!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: responsive.h(0.3)),
                    child: Text(
                      contact.relationship!,
                      style: TextStyle(
                        color: AppColors.onSurfaceFaint(brightness),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Contact',
          style: TextStyle(color: AppColors.onSurface(brightness)),
        ),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your trusted contacts?',
          style: TextStyle(color: AppColors.onSurfaceMuted(brightness)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceMuted(brightness)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(sosNotifierProvider.notifier)
                  .removeContact(oderId, contact.id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
