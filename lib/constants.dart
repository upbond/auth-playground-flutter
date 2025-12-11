import 'package:flutter/material.dart';

const double padding = 16.0;
const double margin = 16.0;

// Colors
const Color primaryColor = Color(0xFF1A1A2E);
const Color accentColor = Color(0xFF4A90A4);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color cardColor = Colors.white;
const Color textPrimary = Color(0xFF333333);
const Color textSecondary = Color(0xFF666666);
const Color textMuted = Color(0xFF999999);

// Upbond Logo URL
const String upbondLogoUrl = 'https://da7udebijaype.cloudfront.net/uploads/startups/logos/c915d3a2-faa5-47c1-952c-45432b0ef32f.png?=1661886060';

// Documentation URL
const String documentationUrl = 'https://upbondocs.gitbook.io/wallet/';

// Generate avatar URL from email
String getAvatarUrl(String? email) {
  return 'https://api.dicebear.com/8.x/shapes/svg?seed=${email ?? 'default'}';
}
