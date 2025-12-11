import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class HeroWidget extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final bool showButtons;

  const HeroWidget({
    this.onLogin,
    this.onRegister,
    this.showButtons = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.network(
              upbondLogoUrl,
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business, size: 60, color: Colors.grey),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Login 3.0 Sample Project',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'UpbondのLogin 3.0 SDKを使用した認証フローを示すサンプルアプリケーションです。',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Documentation link
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(documentationUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text(
                'ドキュメント',
                style: TextStyle(
                  fontSize: 16,
                  color: accentColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            // Buttons (only show when not logged in)
            if (showButtons && onLogin != null && onRegister != null) ...[
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Register button
                  OutlinedButton(
                    onPressed: onRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: textPrimary),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '登録',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Login button
                  ElevatedButton(
                    onPressed: onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ログイン',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
