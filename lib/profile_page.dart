import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'constants.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile? user;
  final Map<String, dynamic>? idTokenData;
  final Map<String, dynamic>? userInfoData;
  final bool isLoading;

  const ProfilePage({
    required this.user,
    this.idTokenData,
    this.userInfoData,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use data from userInfoData API if available
    final name = userInfoData?['name'] ?? user?.name ?? '';
    final email = userInfoData?['email'] ?? user?.email ?? '';
    final pictureUrl = _getPictureUrl();
    final walletAddress = userInfoData?['wallet_address'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: pictureUrl.isNotEmpty
                        ? Image.network(
                            pictureUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 40, color: Colors.grey);
                            },
                          )
                        : const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name.isNotEmpty) ...[
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (walletAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          walletAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Loading indicator
          if (isLoading) ...[
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 24),
          ],

          // User Info from API Section
          if (userInfoData != null && !isLoading) ...[
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildUserInfoApiCard(),
            const SizedBox(height: 24),

            // Identity/Provider Section
            if (_hasIdentities()) ...[
              const Text(
                'Linked Accounts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildIdentitiesCard(),
              const SizedBox(height: 24),
            ],

            // Raw JSON Section (expanded by default)
            const Text(
              'Raw Data (JSON)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildJsonCard(userInfoData!),
          ],

          // IDToken Section
          if (idTokenData != null) ...[
            const Text(
              'From IDToken :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildJsonCard(idTokenData!),
            const SizedBox(height: 24),
          ],

          // Basic User Info if no custom data and not loading
          if (idTokenData == null && userInfoData == null && !isLoading) ...[
            const Text(
              'User Information :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildUserInfoCard(),
          ],
        ],
      ),
    );
  }

  String _getPictureUrl() {
    // Try to get picture from identities first
    if (userInfoData != null && userInfoData!['identities'] != null) {
      final identities = userInfoData!['identities'] as List;
      if (identities.isNotEmpty) {
        final firstIdentity = identities[0];
        final pictureUrl = firstIdentity['user']?['pictureUrl'] ?? '';
        if (pictureUrl.isNotEmpty) {
          return pictureUrl;
        }
      }
    }
    // Fallback to gravatar
    return getAvatarUrl(userInfoData?['email'] ?? user?.email);
  }

  bool _hasIdentities() {
    return userInfoData != null &&
        userInfoData!['identities'] != null &&
        (userInfoData!['identities'] as List).isNotEmpty;
  }

  Widget _buildUserInfoApiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('Name', _emptyToDefault(userInfoData?['name'])),
          _buildInfoRow('First Name', _emptyToDefault(userInfoData?['first_name'])),
          _buildInfoRow('Last Name', _emptyToDefault(userInfoData?['last_name'])),
          _buildInfoRow('Given Name', _emptyToDefault(userInfoData?['given_name'])),
          _buildInfoRow('First Name (Katakana)', _emptyToDefault(userInfoData?['first_name_katakana'])),
          _buildInfoRow('Last Name (Katakana)', _emptyToDefault(userInfoData?['last_name_katakana'])),
          _buildInfoRow('Email', _emptyToDefault(userInfoData?['email'])),
          _buildInfoRow('Email Verified', userInfoData?['email_verified'] == true ? 'Verified' : 'Not Verified'),
          _buildInfoRow('Phone Number', _emptyToDefault(userInfoData?['phone_number'])),
          _buildInfoRow('Phone Verified', userInfoData?['phone_number_verified'] == true ? 'Verified' : 'Not Verified'),
          _buildInfoRow('Birthdate', _emptyToDefault(userInfoData?['birthdate'])),
          _buildInfoRow('Gender', _getGenderDisplay(userInfoData?['gender'])),
          _buildInfoRow('Wallet Address', _emptyToDefault(userInfoData?['wallet_address'])),
          _buildInfoRow('Sub', _emptyToDefault(userInfoData?['sub'])),
          _buildInfoRow('Privacy Policy Agreement', userInfoData?['privacy_policy_agreement'] == true ? 'Agreed' : 'Not Agreed'),
          _buildInfoRow('Created At', _formatDate(userInfoData?['created_at'])),
          _buildInfoRow('Updated At', _formatDate(userInfoData?['updated_at'])),
        ],
      ),
    );
  }

  Widget _buildIdentitiesCard() {
    final identities = userInfoData?['identities'] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: identities.map<Widget>((identity) {
          final provider = identity['provider'] ?? '-';
          final connection = identity['connection'] ?? '-';
          final userId = identity['user_id'] ?? '-';
          final displayName = identity['user']?['displayName'] ?? '-';
          final firstLoginDate = _formatDate(identity['first_login_date']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _getProviderIcon(provider),
                    const SizedBox(width: 8),
                    Text(
                      provider.toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Display Name', displayName),
                _buildInfoRow('User ID', userId),
                _buildInfoRow('Connection', connection),
                _buildInfoRow('First Login', firstLoginDate),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getProviderIcon(String provider) {
    IconData icon;
    Color color;

    switch (provider.toLowerCase()) {
      case 'line':
        icon = Icons.chat_bubble;
        color = const Color(0xFF00B900);
        break;
      case 'google':
        icon = Icons.g_mobiledata;
        color = Colors.red;
        break;
      case 'facebook':
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'twitter':
        icon = Icons.flutter_dash;
        color = const Color(0xFF1DA1F2);
        break;
      default:
        icon = Icons.account_circle;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 24);
  }

  String _emptyToDefault(dynamic value) {
    if (value == null) return '-';
    final str = value.toString().trim();
    return str.isEmpty ? '-' : str;
  }

  String _getGenderDisplay(String? gender) {
    if (gender == null || gender.trim().isEmpty) return '-';
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return gender;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? accentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonCard(Map<String, dynamic> data) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          prettyJson,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF9CDCFE),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('ID', user?.sub ?? '-'),
          _buildInfoRow('Name', user?.name ?? '-'),
          _buildInfoRow('Email', user?.email ?? '-'),
          _buildInfoRow('Email Verified', user?.isEmailVerified?.toString() ?? '-'),
          _buildInfoRow('Updated At', user?.updatedAt?.toIso8601String() ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
