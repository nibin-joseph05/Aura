import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength(password);
    final label = _getLabel(strength);
    final color = _getColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        // Strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              strength >= 0.75
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateStrength(String password) {
    double score = 0;
    if (password.length >= 8) score += 0.2;
    if (password.length >= 12) score += 0.05;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  String _getLabel(double strength) {
    if (strength < 0.3) return "Weak";
    if (strength < 0.5) return "Fair";
    if (strength < 0.75) return "Good";
    return "Strong";
  }

  Color _getColor(double strength) {
    if (strength < 0.3) return Colors.redAccent;
    if (strength < 0.5) return Colors.orangeAccent;
    if (strength < 0.75) return Colors.amber;
    return Colors.greenAccent;
  }
}
