import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/sos_provider.dart';
import '../../data/models/sos_event.dart';

class SOSTriggerScreen extends ConsumerStatefulWidget {
  const SOSTriggerScreen({super.key});

  @override
  ConsumerState<SOSTriggerScreen> createState() => _SOSTriggerScreenState();
}

class _SOSTriggerScreenState extends ConsumerState<SOSTriggerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isTriggering = false;
  bool _isTriggered = false;
  int _countdown = 5;
  Timer? _countdownTimer;
  SOSEvent? _triggeredEvent;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isTriggering = true;
      _countdown = 5;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _triggerSOS();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isTriggering = false;
      _countdown = 5;
    });
  }

  Future<void> _triggerSOS() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final location = await ref.read(currentLocationProvider.future);
    if (location == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get location. Please enable GPS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cancelCountdown();
      return;
    }

    final settings = await ref.read(sosSettingsProvider(user.uid).future);
    final contacts = await ref.read(trustedContactsProvider(user.uid).future);

    int smsCount = 0;
    final mapsUrl =
        'https://www.google.com/maps?q=${location.latitude},${location.longitude}';
    final messageBody =
        '${settings.customMessage}\n\nMy location: $mapsUrl\n\nLat: ${location.latitude}\nLng: ${location.longitude}';

    for (final contact in contacts) {
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          await sendSMS(
            message: messageBody,
            recipients: [contact.phone],
            sendDirect: true,
          );
          smsCount++;
        }
      } catch (_) {
        try {
          final smsUri = Uri(
            scheme: 'sms',
            path: contact.phone,
            queryParameters: {'body': messageBody},
          );
          if (await canLaunchUrl(smsUri)) {
            await launchUrl(smsUri);
            smsCount++;
          }
        } catch (_) {}
      }
    }

    final notifier = ref.read(sosNotifierProvider.notifier);
    final event = await notifier.triggerSOS(
      oderId: user.uid,
      latitude: location.latitude,
      longitude: location.longitude,
      customMessage: settings.customMessage,
      contactsNotified: smsCount,
      deviceInfo:
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    );

    setState(() {
      _isTriggering = false;
      _isTriggered = true;
      _triggeredEvent = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isTriggered
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, responsive),
              Expanded(
                child: _isTriggered
                    ? _buildTriggeredContent(responsive)
                    : _buildTriggerContent(responsive),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Responsive responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(2),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () {
              if (_isTriggering) {
                _cancelCountdown();
              }
              Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              'Emergency SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/sos-settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerContent(Responsive responsive) {
    final user = ref.watch(currentUserProvider);
    final contactsAsync = user != null
        ? ref.watch(trustedContactsProvider(user.uid))
        : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isTriggering) ...[
          Text(
            'Sending SOS in',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 18,
            ),
          ),
          SizedBox(height: responsive.h(2)),
          Text(
            '$_countdown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.h(4)),
          ElevatedButton(
            onPressed: _cancelCountdown,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(10),
                vertical: responsive.h(2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ] else ...[
          Text(
            'Press and hold to trigger SOS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: responsive.h(4)),
          GestureDetector(
            onLongPress: _startCountdown,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: responsive.w(50),
                    height: responsive.w(50),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: responsive.w(15),
                            color: const Color(0xFFFF416C),
                          ),
                          SizedBox(height: responsive.h(1)),
                          Text(
                            'SOS',
                            style: TextStyle(
                              color: const Color(0xFFFF416C),
                              fontSize: responsive.w(8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: responsive.h(4)),
          if (contactsAsync != null)
            contactsAsync.when(
              data: (contacts) => Text(
                '${contacts.length} contacts will be notified',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
        ],
      ],
    );
  }

  Widget _buildTriggeredContent(Responsive responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: responsive.w(25),
            height: responsive.w(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.check_circle,
              size: responsive.w(15),
              color: Colors.green,
            ),
          ),
          SizedBox(height: responsive.h(3)),
          const Text(
            'SOS Sent!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.h(1)),
          Text(
            '${_triggeredEvent?.contactsNotified ?? 0} contacts notified',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: responsive.h(4)),
          Container(
            padding: EdgeInsets.all(responsive.w(4)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70),
                    SizedBox(width: responsive.w(2)),
                    Expanded(
                      child: Text(
                        'Location shared',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(1)),
                Text(
                  '${_triggeredEvent?.latitude.toStringAsFixed(6)}, ${_triggeredEvent?.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(4)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.w(10),
                vertical: responsive.h(2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
